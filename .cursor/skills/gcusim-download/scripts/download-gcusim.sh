#!/bin/bash
# Copyright 2024 Enflame. All Rights Reserved.
# GcuSim Download Script

set -e

ARTIFACT_BASE_URL="http://artifact.enflame.cn/artifactory/release_center/GCUSIM"
ARTIFACT_API_URL="http://artifact.enflame.cn/artifactory/api/storage/release_center/GCUSIM"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOWNLOAD_DIR="."
VERBOSE=0
DRY_RUN=0

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
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
Usage: $0 [OPTIONS]

Download GcuSim simulator libraries from artifact.enflame.cn

OPTIONS:
    --all                   Download all architectures (gcu400, gcu450, gcu500) latest versions
    --arch <arch>           Download specific architecture: gcu400, gcu450, gcu500
    --version <version>     Download specific version (format: 4.5.4, 454, or 45)
    --dir <directory>       Target directory (default: current directory)
    --list                  List available versions
    --verbose               Show verbose output
    --dry-run               Show what would be downloaded without actually downloading
    -h, --help              Show this help message

EXAMPLES:
    # Download all architectures latest versions
    $0 --all

    # Download GCU450 latest version
    $0 --arch gcu450

    # Download specific version (all architectures)
    $0 --version 4.5.4
    $0 --version 454

    # Download GCU450 version 4.5.4
    $0 --arch gcu450 --version 4.5.4

    # Download to specific directory
    $0 --all --dir /opt/gcusim

VERSION FORMATS:
    4.5.4   - Full version number
    454     - Abbreviated (dots removed)
    45      - Major.minor only (finds latest 4.5.x)

ARCHITECTURE MAPPING:
    gcu400  → libgcusim.so      (4.0.x versions)
    gcu450  → libgcusim450.so   (4.5.x versions)
    gcu500  → libgcusim5.so     (5.0.x versions)

EOF
    exit 0
}

normalize_version() {
    local input=$1
    local len=${#input}

    if [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$input"
    elif [[ "$input" =~ ^[0-9]{3}$ ]]; then
        local major="${input:0:1}"
        local minor="${input:1:1}"
        local patch="${input:2:1}"
        echo "${major}.${minor}.${patch}"
    elif [[ "$input" =~ ^[0-9]{2}$ ]]; then
        local major="${input:0:1}"
        local minor="${input:1:1}"
        echo "${major}.${minor}"
    elif [[ "$input" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo "$input"
    else
        log_error "Invalid version format: $input"
        log_error "Supported formats: 4.5.4, 454, 45"
        exit 1
    fi
}

get_version_prefix() {
    local arch=$1
    case "$arch" in
        gcu400) echo "4.0" ;;
        gcu450) echo "4.5" ;;
        gcu500) echo "5.0" ;;
        *)
            log_error "Unknown architecture: $arch"
            exit 1
            ;;
    esac
}

get_lib_name() {
    local arch=$1
    case "$arch" in
        gcu400) echo "libgcusim.so" ;;
        gcu450) echo "libgcusim450.so" ;;
        gcu500) echo "libgcusim5.so" ;;
        *)
            log_error "Unknown architecture: $arch"
            exit 1
            ;;
    esac
}

list_available_versions() {
    local arch=$1
    local prefix=$(get_version_prefix "$arch")

    log_info "Fetching available versions for $arch (${prefix}.x)..."

    local html=$(curl -s "$ARTIFACT_BASE_URL/")
    if [ $? -ne 0 ]; then
        log_error "Failed to fetch version list from $ARTIFACT_BASE_URL"
        exit 1
    fi

    local versions=$(echo "$html" | grep -oP 'href="[0-9.]+/"' | grep -oP '[0-9.]+' | grep "^${prefix}\." | sort -t. -k3 -u)

    if [ -z "$versions" ]; then
        log_warn "No versions found for $arch"
        return 1
    fi

    echo "Available versions for $arch:"
    echo "$versions" | while read -r ver; do
        echo "  - $ver"
    done
}

get_latest_version() {
    local arch=$1
    local prefix=$(get_version_prefix "$arch")

    log_verbose "Fetching latest version for $arch (${prefix}.x)..."

    local html=$(curl -s "$ARTIFACT_BASE_URL/")
    if [ $? -ne 0 ]; then
        log_error "Failed to fetch version list from $ARTIFACT_BASE_URL"
        exit 1
    fi

    local latest=$(echo "$html" | grep -oP 'href="[0-9.]+/"' | grep -oP '[0-9.]+' | grep "^${prefix}\." | sort -t. -k3 | tail -1)

    if [ -z "$latest" ]; then
        log_error "No versions found for $arch"
        exit 1
    fi

    echo "$latest"
}

find_matching_version() {
    local arch=$1
    local partial_version=$2
    local prefix=$(get_version_prefix "$arch")

    log_verbose "Finding versions matching ${partial_version} for $arch..."

    local html=$(curl -s "$ARTIFACT_BASE_URL/")
    if [ $? -ne 0 ]; then
        log_error "Failed to fetch version list"
        exit 1
    fi

    local matched=$(echo "$html" | grep -oP 'href="[0-9.]+/"' | grep -oP '[0-9.]+' | grep "^${partial_version}\." | sort -t. -k3 | tail -1)

    if [ -z "$matched" ]; then
        log_error "No version found matching ${partial_version} for $arch"
        exit 1
    fi

    echo "$matched"
}

download_file() {
    local arch=$1
    local version=$2
    local target_dir=$3

    local lib_name=$(get_lib_name "$arch")
    local url="${ARTIFACT_BASE_URL}/${version}/${lib_name}"
    local target_path="${target_dir}/${lib_name}"

    log_verbose "URL: $url"
    log_verbose "Target: $target_path"

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[DRY-RUN] Would download: $url → $target_path"
        return 0
    fi

    echo "Downloading ${lib_name} (${version})..."

    if ! curl -L --retry 3 --retry-delay 2 -C - --progress-bar -o "${target_path}" "$url"; then
        log_error "Failed to download ${lib_name} from $url"
        return 1
    fi

    local size=$(du -h "$target_path" | cut -f1)
    log_info "Downloaded to ${target_path} (${size})"

    return 0
}

download_arch() {
    local arch=$1
    local version=$2
    local target_dir=$3

    if [ -z "$version" ]; then
        log_verbose "Detecting latest version for $arch..."
        version=$(get_latest_version "$arch")
        log_verbose "Latest version for $arch: $version"
    fi

    download_file "$arch" "$version" "$target_dir"
}

main() {
    local download_all=0
    local arch=""
    local version=""
    local list_versions=0

    if [ $# -eq 0 ]; then
        usage
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                download_all=1
                shift
                ;;
            --arch)
                arch="$2"
                shift 2
                ;;
            --version)
                version=$(normalize_version "$2")
                shift 2
                ;;
            --dir)
                DOWNLOAD_DIR="$2"
                shift 2
                ;;
            --list)
                list_versions=1
                shift
                ;;
            --verbose)
                VERBOSE=1
                shift
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done

    if [ "$list_versions" -eq 1 ]; then
        if [ -n "$arch" ]; then
            list_available_versions "$arch"
        else
            for a in gcu400 gcu450 gcu500; do
                list_available_versions "$a"
                echo ""
            done
        fi
        exit 0
    fi

    if [ ! -d "$DOWNLOAD_DIR" ]; then
        log_error "Directory does not exist: $DOWNLOAD_DIR"
        exit 1
    fi

    DOWNLOAD_DIR=$(cd "$DOWNLOAD_DIR" && pwd)
    log_verbose "Download directory: $DOWNLOAD_DIR"

    echo "Downloading GcuSim libraries..."

    if [ "$download_all" -eq 1 ]; then
        if [ -n "$version" ]; then
            log_info "Detected versions:"
            echo "  - GCU400: $version"
            echo "  - GCU450: $version"
            echo "  - GCU500: $version"
            echo ""
        else
            local v400=$(get_latest_version "gcu400")
            local v450=$(get_latest_version "gcu450")
            local v500=$(get_latest_version "gcu500")
            log_info "Detected latest versions:"
            echo "  - GCU400: $v400"
            echo "  - GCU450: $v450"
            echo "  - GCU500: $v500"
            echo ""
        fi

        local failed=0
        for arch in gcu400 gcu450 gcu500; do
            if ! download_arch "$arch" "$version" "$DOWNLOAD_DIR"; then
                failed=1
            fi
        done

        if [ "$failed" -eq 0 ]; then
            echo ""
            log_info "All downloads completed successfully!"
        else
            echo ""
            log_error "Some downloads failed"
            exit 1
        fi
    elif [ -n "$arch" ]; then
        if [ -z "$version" ]; then
            version=$(get_latest_version "$arch")
            log_verbose "Using latest version: $version"
        fi

        if download_arch "$arch" "$version" "$DOWNLOAD_DIR"; then
            echo ""
            log_info "Download completed successfully!"
        else
            exit 1
        fi
    elif [ -n "$version" ]; then
        local normalized_version="$version"
        if [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
            log_warn "Partial version specified, finding matching versions..."
        fi

        local failed=0
        for arch in gcu400 gcu450 gcu500; do
            local full_version="$normalized_version"
            if [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
                full_version=$(find_matching_version "$arch" "$version")
                log_verbose "Matched version for $arch: $full_version"
            fi

            if ! download_arch "$arch" "$full_version" "$DOWNLOAD_DIR"; then
                failed=1
            fi
        done

        if [ "$failed" -eq 0 ]; then
            echo ""
            log_info "All downloads completed successfully!"
        else
            echo ""
            log_error "Some downloads failed"
            exit 1
        fi
    else
        log_error "Must specify --all, --arch, or --version"
        usage
    fi
}

main "$@"
