#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

WS_DIR="$(workspace_dir "${1:-$PWD}")"
FORCE_INGEST="${2:-no}"  # yes | no

load_config_env
mkdir -p "$BINDINGS_DIR" "$PALACE_ROOT"

if source_binding "$WS_DIR"; then
  ensure_mcp_config "$WS_DIR" "$FAMILY"
  if [[ "$FORCE_INGEST" == "yes" ]]; then
    if bash "$SCRIPT_DIR/ingest.sh" "$WS_DIR" "incremental"; then
      echo "[mempalace-memory] Already bound; forced incremental ingest done."
    else
      echo "[mempalace-memory] Already bound; forced ingest failed."
    fi
    exit 0
  fi
  echo "[mempalace-memory] Already bound: $WS_DIR -> $PALACE_PATH"
  exit 0
fi

FAMILY="$(detect_family "$WS_DIR")"
PALACE_HINT_FILE="$WS_DIR/.mempalace-palace"
if [[ -f "$PALACE_HINT_FILE" ]]; then
  PALACE_PATH="$(tr -d '\r\n' < "$PALACE_HINT_FILE")"
else
  PALACE_PATH="$PALACE_ROOT/$FAMILY"
fi

mkdir -p "$PALACE_PATH"
echo "$FAMILY" > "$WS_DIR/.mempalace-family"
echo "$PALACE_PATH" > "$PALACE_HINT_FILE"

if mempalace --palace "$PALACE_PATH" status 2>&1 | rg -q "No palace found"; then
  mempalace --palace "$PALACE_PATH" init "$WS_DIR" --yes >/dev/null
fi

write_binding "$WS_DIR" "$FAMILY" "$PALACE_PATH"
ensure_mcp_config "$WS_DIR" "$FAMILY"

echo "[mempalace-memory] Bound: $WS_DIR -> $PALACE_PATH"
if ! bash "$SCRIPT_DIR/ingest.sh" "$WS_DIR" "full"; then
  echo "[mempalace-memory] Bind succeeded but full ingest failed."
fi

