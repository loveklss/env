#!/bin/bash
set -euo pipefail

CONTAINER="$(whoami)_dev"
MAX_JOBS=45

usage() {
    cat <<'EOF'
Usage: caps-build.sh [OPTIONS] [TARGET...]

Options:
  --src DIR         Caps source root (default: current directory)
  --debug           Use CMAKE_BUILD_TYPE=Debug
  --cmake           Force re-run cmake even if build.ninja exists
  --auto            Auto-detect targets from git changes
  --rpm             Build RPM packages instead of DEB (default: DEB)
  --install         Install built packages after building (requires sudo)
  --install-only    Skip build, only install existing packages (requires sudo)
  -j N              Set parallel jobs (default: 45)
  -h, --help        Show this help

Targets (if omitted with --auto, auto-detect from git; otherwise default to package_topsruntime_deb):
  package_topsruntime_deb       Runtime (efdrv + topsrt + lepton)
  package_topscc_deb            Compiler (rtcu + topscc + sanitizer)
  package_topsprof_deb          Profiler
  package_topspti_deb           PTI
  package_topsgdb_deb           GDB debugger
  package_topsdbgapi_deb        Debug API
  package_topstx_deb            TopsTX
  package_tops_sanitizer_deb    Sanitizer
  package_topscodec_deb         Codec library
  package_topsfile_deb          File library
  package_mori_gcu_deb          Mori
  package_efml_deb              EFML
  package_efsmi_deb             EFSMI
  package_efnetq_client_deb     EFNETQ client
  package_efnetq_agent_deb      EFNETQ agent
  package_enflame_persistenced_deb  Persistenced
  package_kmd                   Kernel mode driver
  package_topscc_samples        Samples
  package_all_deb               All deb packages
  package_all                   Everything
  (Use --rpm to build _rpm versions instead of _deb)

Examples:
  caps-build.sh --auto
  caps-build.sh --rpm --auto
  caps-build.sh --debug package_efsmi_deb
  caps-build.sh --rpm package_topsruntime_rpm
  caps-build.sh --cmake --debug
  caps-build.sh package_topsruntime_deb package_efsmi_deb
  caps-build.sh --auto --install
  caps-build.sh --install-only package_efsmi_deb
EOF
    exit 0
}

CAPS_SRC="$(pwd)"
BUILD_TYPE=""
FORCE_CMAKE=false
AUTO_DETECT=false
PKG_TYPE="deb"
DO_INSTALL=false
INSTALL_ONLY=false
TARGETS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --src)          CAPS_SRC="$(cd "$2" && pwd)"; shift 2 ;;
        --debug)        BUILD_TYPE="Debug"; shift ;;
        --cmake)        FORCE_CMAKE=true; shift ;;
        --auto)         AUTO_DETECT=true; shift ;;
        --rpm)          PKG_TYPE="rpm"; shift ;;
        --install)      DO_INSTALL=true; shift ;;
        --install-only) INSTALL_ONLY=true; DO_INSTALL=true; shift ;;
        -j)             MAX_JOBS="$2"; shift 2 ;;
        -h|--help)      usage ;;
        -*)             echo "Unknown option: $1"; usage ;;
        *)              TARGETS+=("$1"); shift ;;
    esac
done

CAPS_DIR_NAME="$(basename "$CAPS_SRC")"
BUILD_DIR="$(dirname "$CAPS_SRC")/runtime_build"

path_to_target() {
    local file="$1"
    local target=""
    case "$file" in
        runtime/*)                        target="package_topsruntime" ;;
        lepton/*)                         target="package_topsruntime" ;;
        compiler/*)                       target="package_topscc" ;;
        devtools/topsprof/*)              target="package_topsprof" ;;
        devtools/topspti/*)               target="package_topspti" ;;
        devtools/topspti_external/*)      target="package_topspti" ;;
        devtools/topsgdb/*)               target="package_topsgdb" ;;
        devtools/topsdbgapi/*)            target="package_topsdbgapi" ;;
        devtools/topstx/*)                target="package_topstx" ;;
        devtools/tops_sanitizer/*)        target="package_tops_sanitizer" ;;
        devtools/topsbit/*)               echo "topsbit"; return ;;
        devtools/topsbuf/*)               target="package_topsruntime" ;;
        devtools/topsrt_hook/*)           target="package_topsruntime" ;;
        libs/topscodec/*)                 target="package_topscodec" ;;
        libs/topsfile/*)                  target="package_topsfile" ;;
        libs/mori/*)                      target="package_mori_gcu" ;;
        utilities/efml/*)                 target="package_efml" ;;
        utilities/pyefml/*)               target="package_efml" ;;
        utilities/efsmi/*)                target="package_efsmi" ;;
        utilities/efnetq/*)               target="package_efnetq_client" ;;
        utilities/enflame-persistenced/*) target="package_enflame_persistenced" ;;
        utilities/topsenvcheck/*)         echo "package_topsenvcheck"; return ;;
        samples/*)                        echo "package_topscc_samples"; return ;;
        package/*)                        echo "package_kmd"; return ;;
        kmd/*)                            echo "package_kmd"; return ;;
        cmake/*)                          target="package_topsruntime" ;;
        *)                                return ;;
    esac
    if [[ -n "$target" ]]; then
        echo "${target}_${PKG_TYPE}"
    fi
}

detect_targets() {
    local changed_files
    changed_files=$(cd "$CAPS_SRC" && {
        git diff --name-only 2>/dev/null
        git diff --cached --name-only 2>/dev/null
        git ls-files --others --exclude-standard 2>/dev/null
    } | sort -u)

    local detected=()
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        local t
        t=$(path_to_target "$file")
        [[ -n "$t" ]] && detected+=("$t")
    done <<< "$changed_files"

    local unique
    unique=$(printf '%s\n' "${detected[@]}" 2>/dev/null | sort -u)
    if [[ -z "$unique" ]]; then
        echo "package_topsruntime_deb"
    else
        echo "$unique"
    fi
}

run_in_container() {
    if docker exec -i -u "$(id -u):$(id -g)" "$CONTAINER" bash -c "$1"; then
        return 0
    fi
    local rc=$?
    if [[ $rc -eq 125 || $rc -eq 126 || $rc -eq 127 ]]; then
        echo "==> Container not running, starting with: efdocker run dev -u $(id -u):$(id -g)"
        efdocker run dev -u "$(id -u):$(id -g)"
        docker exec -i -u "$(id -u):$(id -g)" "$CONTAINER" bash -c "$1"
    else
        return $rc
    fi
}

detect_container_pkg_type() {
    local detect_cmd="if command -v dpkg >/dev/null 2>&1; then echo 'deb'; elif command -v rpm >/dev/null 2>&1; then echo 'rpm'; else echo 'unknown'; fi"
    local result
    result=$(docker exec -i "$CONTAINER" bash -c "$detect_cmd" 2>/dev/null || echo "unknown")
    echo "$result"
}

if $AUTO_DETECT && [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo "==> Auto-detecting targets from git changes..."
    while IFS= read -r t; do
        [[ -n "$t" ]] && TARGETS+=("$t")
    done <<< "$(detect_targets)"
    echo "==> Detected targets: ${TARGETS[*]}"
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    TARGETS=("package_topsruntime_${PKG_TYPE}")
fi

# Detect container package type if installing
CONTAINER_PKG_TYPE=""
if $DO_INSTALL; then
    echo "==> Detecting container package system..."
    CONTAINER_PKG_TYPE=$(detect_container_pkg_type)
    if [[ "$CONTAINER_PKG_TYPE" == "unknown" ]]; then
        echo "==> Error: Cannot detect package system in container (no dpkg or rpm found)"
        exit 1
    fi
    echo "==> Container package system: $CONTAINER_PKG_TYPE"
    if $INSTALL_ONLY; then
        echo "==> Install-only mode: skipping build"
    fi
fi

# Step 1: ensure build directory exists
BUILD_CMDS="mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR}"

# Step 2: cmake only when needed
NEED_CMAKE=false
CURRENT_IS_DEBUG=false
if [[ -f "${BUILD_DIR}/CMakeCache.txt" ]]; then
    CACHED_TYPE=$(grep -m1 '^CMAKE_BUILD_TYPE:' "${BUILD_DIR}/CMakeCache.txt" \
        | cut -d= -f2)
    [[ "$CACHED_TYPE" == "Debug" ]] && CURRENT_IS_DEBUG=true
fi
WANT_DEBUG=false
[[ "$BUILD_TYPE" == "Debug" ]] && WANT_DEBUG=true

if $FORCE_CMAKE; then
    NEED_CMAKE=true
elif [[ ! -f "${BUILD_DIR}/build.ninja" ]]; then
    NEED_CMAKE=true
elif $WANT_DEBUG && ! $CURRENT_IS_DEBUG; then
    echo "==> Switching to Debug, re-running cmake"
    NEED_CMAKE=true
elif ! $WANT_DEBUG && $CURRENT_IS_DEBUG; then
    echo "==> Switching from Debug to default, re-running cmake"
    NEED_CMAKE=true
fi

if $NEED_CMAKE; then
    CMAKE_CMD="cmake ../${CAPS_DIR_NAME} -G Ninja"
    if $WANT_DEBUG; then
        CMAKE_CMD+=" -DCMAKE_BUILD_TYPE=Debug"
    elif $CURRENT_IS_DEBUG; then
        CMAKE_CMD+=" -DCMAKE_BUILD_TYPE="
    fi
    BUILD_CMDS+=" && ${CMAKE_CMD}"
fi

# Step 3: build each target (skip if install-only)
if ! $INSTALL_ONLY; then
    for target in "${TARGETS[@]}"; do
        BUILD_CMDS+=" && ninja ${target} -j${MAX_JOBS}"
    done
fi

# Step 4: install packages if requested
if $DO_INSTALL; then
    BUILD_CMDS+=" && echo '==> Installing packages in container...'"
    for target in "${TARGETS[@]}"; do
        TARGET_NAME="${target#package_}"
        TARGET_NAME="${TARGET_NAME%_deb}"
        TARGET_NAME="${TARGET_NAME%_rpm}"

        if [[ "$CONTAINER_PKG_TYPE" == "deb" ]]; then
            if [[ "$target" == "package_all_deb" || "$target" == "package_all" || "$target" == "package_all_rpm" ]]; then
                BUILD_CMDS+=" && (echo '==> Installing all DEB packages'; sudo dpkg -i ${BUILD_DIR}/*.deb 2>/dev/null || true; sudo apt-get install -f -y)"
            else
                BUILD_CMDS+=" && (PKG_FILES=\$(find ${BUILD_DIR} -maxdepth 1 -name '*${TARGET_NAME}*.deb' 2>/dev/null | head -1); if [[ -n \"\$PKG_FILES\" ]]; then echo '==> Installing: '\$PKG_FILES; sudo dpkg -i \$PKG_FILES || true; sudo apt-get install -f -y; else echo '==> Warning: No DEB package found for ${TARGET_NAME}'; fi)"
            fi
        elif [[ "$CONTAINER_PKG_TYPE" == "rpm" ]]; then
            if [[ "$target" == "package_all_deb" || "$target" == "package_all" || "$target" == "package_all_rpm" ]]; then
                BUILD_CMDS+=" && (echo '==> Installing all RPM packages'; sudo rpm -Uvh --force ${BUILD_DIR}/*.rpm 2>/dev/null || true)"
            else
                BUILD_CMDS+=" && (PKG_FILES=\$(find ${BUILD_DIR} -maxdepth 1 -name '*${TARGET_NAME}*.rpm' 2>/dev/null | head -1); if [[ -n \"\$PKG_FILES\" ]]; then echo '==> Installing: '\$PKG_FILES; sudo rpm -Uvh --force \$PKG_FILES || true; else echo '==> Warning: No RPM package found for ${TARGET_NAME}'; fi)"
            fi
        fi
    done
    BUILD_CMDS+=" && echo '==> Installation complete in container'"
fi

echo "==> Source: ${CAPS_SRC}"
echo "==> Build:  ${BUILD_DIR}"
if ! $INSTALL_ONLY; then
    echo "==> CMake:  $(if $NEED_CMAKE; then echo 'yes'; else echo 'skip (build.ninja exists)'; fi)"
    echo "==> Debug:  $(if [[ "$BUILD_TYPE" == "Debug" ]]; then echo 'yes'; else echo 'no'; fi)"
    echo "==> Package: ${PKG_TYPE}"
fi
echo "==> Targets: ${TARGETS[*]}"
echo "==> Container: ${CONTAINER}"
if $DO_INSTALL; then
    echo "==> Install: yes (in container, using $CONTAINER_PKG_TYPE)"
    if $INSTALL_ONLY; then
        echo "==> Mode: install-only (skip build)"
    fi
else
    echo "==> Install: no"
fi
echo ""

run_in_container "$BUILD_CMDS"
