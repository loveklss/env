#!/bin/bash
# Copyright 2024 Enflame. All Rights Reserved.
# Test Runner Script - Compile and execute TOPS test programs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CACHE_FILE="${SKILL_DIR}/arch-cache.json"
WORKSPACE_ROOT="/home/stephen.hu/ws/gitee/caps"
CONTAINER_NAME="$(whoami)_dev"

VERBOSE=0
COMPILE_ONLY=0
RUN_ONLY=0
NO_CACHE=0
CLEAN_MODE=0

ARCHS=()
INPUT_FILES=()
COMPILED_BINARIES=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo "[DEBUG] $*"
    fi
}

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <files/directories>

Compile and run TOPS test programs with automatic dependency management.

OPTIONS:
    --arch <arch>           Specify architecture (gcu400, gcu450, gcu500), can be used multiple times
    --compile-only          Only compile, do not execute
    --run-only              Only execute already compiled programs
    --clean                 Clean compiled outputs
    --no-cache              Do not use arch cache
    --verbose               Show verbose output
    -h, --help              Show this help message

EXAMPLES:
    # Compile single file (use cached arch)
    $0 test.cpp
    
    # Compile with specific arch
    $0 --arch gcu450 test.cpp
    
    # Compile with multiple archs
    $0 --arch gcu450 --arch gcu500 test.cpp
    
    # Compile all files in directory
    $0 --arch gcu450 samples/Samples/0_Introduction/simpleVectorAdd/
    
    # Only execute already compiled program
    $0 --run-only --arch gcu450 test.cpp

ARCH CACHE:
    The script caches the last used arch(s) in: $CACHE_FILE
    Next time you compile without --arch, it will use the cached arch.

DEPENDENCIES:
    - topscc compiler (auto-installed via caps-build if missing)
    - topsruntime library (auto-installed via caps-build if missing)
    - gcusim library (auto-downloaded via gcusim-download if missing)

OUTPUT LOCATION:
    Compiled binaries are placed in: <source_dir>/bin/<arch>/<binary_name>
    Example: test.cpp -> bin/gcu450/test

EOF
    exit 0
}

load_cached_archs() {
    if [ -f "$CACHE_FILE" ] && [ "$NO_CACHE" -eq 0 ]; then
        local cached=$(jq -r '.last_archs[]' "$CACHE_FILE" 2>/dev/null)
        if [ -n "$cached" ]; then
            log_verbose "Loaded cached archs: $cached"
            echo "$cached"
        fi
    fi
}

save_cached_archs() {
    local archs=("$@")
    if [ "$NO_CACHE" -eq 0 ]; then
        local archs_str=$(printf '%s\n' "${archs[@]}" | jq -R . | jq -s .)
        local json=$(jq -n --argjson archs "$archs_str" \
            '{last_archs: $archs, timestamp: now | todate}')
        echo "$json" > "$CACHE_FILE"
        log_verbose "Saved archs to cache: ${archs[*]}"
    fi
}

get_gcusim_lib() {
    case "$1" in
        gcu400) echo "libgcusim.so" ;;
        gcu450) echo "libgcusim450.so" ;;
        gcu500) echo "libgcusim5.so" ;;
        *)
            log_error "Unknown architecture: $1"
            exit 1
            ;;
    esac
}

get_internal_gcu_sim() {
    case "$1" in
        gcu400) echo "LIBRA" ;;
        gcu450) echo "LIBRAH" ;;
        gcu500) echo "DRACO" ;;
        *)
            log_error "Unknown architecture: $1"
            exit 1
            ;;
    esac
}

check_container() {
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_error "Container '${CONTAINER_NAME}' is not running"
        log_info "Starting container..."
        if ! efdocker run dev -u $(id -u):$(id -g); then
            log_error "Failed to start container"
            exit 1
        fi
        sleep 2
    fi
    log_verbose "Container ${CONTAINER_NAME} is running"
}

check_and_install_topscc() {
    log_verbose "Checking topscc..."
    
    if docker exec -u "$(id -u):$(id -g)" ${CONTAINER_NAME} test -f /opt/tops/bin/topscc 2>/dev/null; then
        log_verbose "topscc found"
        return 0
    fi
    
    log_warn "topscc not found, installing..."
    log_info "Installing topscc and topsruntime packages..."
    
    if ! ~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_topscc_deb; then
        log_error "Failed to install topscc"
        exit 1
    fi
    
    if ! ~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_topsruntime_deb; then
        log_error "Failed to install topsruntime"
        exit 1
    fi
    
    log_success "topscc and topsruntime installed"
}

check_and_download_gcusim() {
    local arch=$1
    local gcusim_lib=$(get_gcusim_lib "$arch")
    
    log_verbose "Checking $gcusim_lib..."
    
    if [ -f "${WORKSPACE_ROOT}/${gcusim_lib}" ]; then
        log_verbose "$gcusim_lib found"
        return 0
    fi
    
    log_warn "$gcusim_lib not found, downloading..."
    
    if ! ~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --arch "$arch" --dir "$WORKSPACE_ROOT"; then
        log_error "Failed to download $gcusim_lib"
        exit 1
    fi
    
    log_success "$gcusim_lib downloaded"
}

is_valid_arch() {
    local arch=$1
    case "$arch" in
        gcu400|gcu450|gcu500)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

parse_input_files() {
    local inputs=("$@")
    local files=()
    
    for input in "${inputs[@]}"; do
        if is_valid_arch "$input"; then
            log_warn "Found architecture '$input' in file list. Did you mean '--arch $input'?" >&2
            log_warn "Skipping '$input' as it's not a valid file/directory path." >&2
            continue
        fi
        
        if [ -f "$input" ]; then
            if [[ "$input" == *.cpp ]]; then
                files+=("$input")
            else
                log_warn "Skipping non-cpp file: $input" >&2
            fi
        elif [ -d "$input" ]; then
            while IFS= read -r -d '' file; do
                files+=("$file")
            done < <(find "$input" -name "*.cpp" -type f -print0 2>/dev/null)
            
            if [ ${#files[@]} -eq 0 ]; then
                log_warn "No .cpp files found in directory: $input" >&2
            fi
        else
            local expanded=$(ls $input 2>/dev/null)
            if [ -n "$expanded" ]; then
                for f in $expanded; do
                    if [[ "$f" == *.cpp ]]; then
                        files+=("$f")
                    fi
                done
            else
                log_warn "File or directory not found: $input" >&2
            fi
        fi
    done
    
    printf '%s\n' "${files[@]}"
}

compile_file() {
    local source_file=$1
    local arch=$2
    
    local abs_source=$(realpath "$source_file")
    local source_dir=$(dirname "$abs_source")
    local source_name=$(basename "$source_file" .cpp)
    local output_dir="${source_dir}/bin/${arch}"
    local output_file="${output_dir}/${source_name}"
    local compile_log="${output_dir}/${source_name}.compile.log"
    
    mkdir -p "$output_dir"
    
    local compile_cmd="cd ${abs_source%/*} && topscc $(basename "$abs_source") -std=c++17 -Werror -Wall -arch $arch \
        -I/opt/tops/include -I${WORKSPACE_ROOT}/samples/Common -ltops -lpthread \
        -Wl,-rpath /opt/tops/lib -o $output_file"
    
    log_info "Compiling $(basename "$source_file") for $arch..."
    log_verbose "Command: $compile_cmd"
    
    if docker exec -u "$(id -u):$(id -g)" ${CONTAINER_NAME} bash -c "$compile_cmd" > "$compile_log" 2>&1; then
        log_success "Compiled: $output_file"
        COMPILED_BINARIES+=("$output_file:$arch")
        return 0
    else
        log_error "Compilation failed for $source_file ($arch)"
        echo ""
        echo "=== Compilation Error Log ==="
        cat "$compile_log"
        echo "=== End of Log ==="
        echo ""
        return 1
    fi
}

execute_binary() {
    local binary=$1
    local arch=$2
    
    local abs_binary=$(realpath "$binary")
    local run_log="${abs_binary}.run.log"
    
    local env_sim=$(get_internal_gcu_sim "$arch")
    local gcusim_lib=$(get_gcusim_lib "$arch")
    local env_setup="export INTERNAL_GCU_SIM=$env_sim && export LD_LIBRARY_PATH=${WORKSPACE_ROOT}:${WORKSPACE_ROOT}/lib:\$LD_LIBRARY_PATH:/opt/tops/lib"
    local exec_cmd="$env_setup && $abs_binary"
    
    log_info "Executing $(basename "$binary") ($arch)..."
    log_verbose "Environment: INTERNAL_GCU_SIM=$env_sim"
    log_verbose "LD_LIBRARY_PATH: ${WORKSPACE_ROOT}:${WORKSPACE_ROOT}/lib:\$LD_LIBRARY_PATH:/opt/tops/lib"
    
    if docker exec -u "$(id -u):$(id -g)" ${CONTAINER_NAME} bash -c "$exec_cmd" > "$run_log" 2>&1; then
        log_success "PASS: $(basename "$binary") ($arch)"
        log_verbose "Log saved to: $run_log"
        return 0
    else
        local exit_code=$?
        log_error "FAIL: $(basename "$binary") ($arch) [exit code: $exit_code]"
        echo ""
        echo "=== Last 50 lines of execution log ==="
        tail -50 "$run_log"
        echo "=== End of Log ==="
        echo ""
        echo "Full log saved to: $run_log"
        return 1
    fi
}

clean_outputs() {
    local source_file=$1
    local source_dir=$(dirname "$(realpath "$source_file")")
    local bin_dir="${source_dir}/bin"
    
    if [ -d "$bin_dir" ]; then
        log_info "Cleaning: $bin_dir"
        rm -rf "$bin_dir"
        log_success "Cleaned"
    else
        log_info "No outputs to clean for $source_file"
    fi
}

main() {
    if [ $# -eq 0 ]; then
        usage
    fi
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --arch)
                if [ -z "$2" ]; then
                    log_error "--arch requires an argument"
                    log_info "Available archs: gcu400, gcu450, gcu500"
                    exit 1
                fi
                if ! is_valid_arch "$2"; then
                    log_error "Invalid architecture: $2"
                    log_info "Available archs: gcu400, gcu450, gcu500"
                    exit 1
                fi
                ARCHS+=("$2")
                shift 2
                ;;
            --compile-only)
                COMPILE_ONLY=1
                shift
                ;;
            --run-only)
                RUN_ONLY=1
                shift
                ;;
            --clean)
                CLEAN_MODE=1
                shift
                ;;
            --no-cache)
                NO_CACHE=1
                shift
                ;;
            --verbose)
                VERBOSE=1
                shift
                ;;
            -h|--help)
                usage
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                ;;
            *)
                if is_valid_arch "$1"; then
                    log_warn "Architecture '$1' detected without --arch flag"
                    log_info "Auto-adding architecture: $1"
                    ARCHS+=("$1")
                else
                    INPUT_FILES+=("$1")
                fi
                shift
                ;;
        esac
    done
    
    if [ ${#INPUT_FILES[@]} -eq 0 ]; then
        log_error "No input files or directories specified"
        usage
    fi
    
    local files=()
    while IFS= read -r file; do
        [ -n "$file" ] && files+=("$file")
    done < <(parse_input_files "${INPUT_FILES[@]}")
    
    if [ ${#files[@]} -eq 0 ]; then
        log_error "No .cpp files found"
        exit 1
    fi
    
    log_info "Found ${#files[@]} file(s) to process"
    for f in "${files[@]}"; do
        log_verbose "  - $f"
    done
    
    if [ "$CLEAN_MODE" -eq 1 ]; then
        for file in "${files[@]}"; do
            clean_outputs "$file"
        done
        exit 0
    fi
    
    if [ ${#ARCHS[@]} -eq 0 ] && [ "$NO_CACHE" -eq 0 ]; then
        local cached_archs=($(load_cached_archs))
        if [ ${#cached_archs[@]} -gt 0 ]; then
            ARCHS=("${cached_archs[@]}")
            log_info "Using cached arch(s): ${ARCHS[*]}"
        fi
    fi
    
    if [ ${#ARCHS[@]} -eq 0 ]; then
        log_error "No architecture specified and no cached arch found"
        log_info "Please specify arch using --arch option"
        log_info "Available archs: gcu400, gcu450, gcu500"
        exit 1
    fi
    
    save_cached_archs "${ARCHS[@]}"
    
    check_container
    
    if [ "$RUN_ONLY" -eq 0 ]; then
        for arch in "${ARCHS[@]}"; do
            log_info "Preparing for arch: $arch"
            
            check_and_install_topscc
            check_and_download_gcusim "$arch"
            
            echo ""
            log_info "Compiling ${#files[@]} file(s) for $arch..."
            echo ""
            
            local compile_failed=0
            for file in "${files[@]}"; do
                if ! compile_file "$file" "$arch"; then
                    compile_failed=1
                    break
                fi
            done
            
            if [ "$compile_failed" -eq 1 ]; then
                log_error "Compilation failed for $arch, stopping this arch"
                echo ""
            else
                log_success "All files compiled successfully for $arch"
                echo ""
            fi
        done
    else
        for arch in "${ARCHS[@]}"; do
            for file in "${files[@]}"; do
                local source_dir=$(dirname "$(realpath "$file")")
                local source_name=$(basename "$file" .cpp)
                local binary="${source_dir}/bin/${arch}/${source_name}"
                
                if [ -f "$binary" ]; then
                    COMPILED_BINARIES+=("$binary:$arch")
                else
                    log_warn "Binary not found: $binary"
                fi
            done
        done
    fi
    
    if [ "$COMPILE_ONLY" -eq 1 ]; then
        log_info "Compile-only mode, skipping execution"
        exit 0
    fi
    
    if [ ${#COMPILED_BINARIES[@]} -eq 0 ]; then
        log_warn "No binaries to execute"
        exit 0
    fi
    
    echo ""
    log_info "Executing ${#COMPILED_BINARIES[@]} test(s)..."
    echo ""
    
    local total_pass=0
    local total_fail=0
    
    for entry in "${COMPILED_BINARIES[@]}"; do
        local binary="${entry%:*}"
        local arch="${entry##*:}"
        
        if execute_binary "$binary" "$arch"; then
            ((total_pass++))
        else
            ((total_fail++))
        fi
        echo ""
    done
    
    echo "================================"
    echo "Test Results Summary"
    echo "================================"
    echo "Total: ${#COMPILED_BINARIES[@]}"
    echo -e "${GREEN}PASS: $total_pass${NC}"
    echo -e "${RED}FAIL: $total_fail${NC}"
    echo "================================"
    
    if [ "$total_fail" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
