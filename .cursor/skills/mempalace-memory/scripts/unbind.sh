#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

WS_DIR="$(workspace_dir "${1:-$PWD}")"
load_config_env

BIND_FILE="$(binding_file "$WS_DIR")"
if [[ ! -f "$BIND_FILE" ]]; then
  echo "[mempalace-memory] Workspace not bound: $WS_DIR"
  exit 0
fi

rm -f "$BIND_FILE"
rm -f "$WS_DIR/.cursor/mcp.json"

echo "[mempalace-memory] Unbound workspace: $WS_DIR"
echo "[mempalace-memory] Palace records are kept unchanged."

