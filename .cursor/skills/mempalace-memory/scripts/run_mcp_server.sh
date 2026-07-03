#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

WS_DIR="$(workspace_dir "${1:-$PWD}")"
load_config_env

if ! source_binding "$WS_DIR"; then
  bash "$SCRIPT_DIR/bind.sh" "$WS_DIR" "no"
  source_binding "$WS_DIR"
fi

exec python3 -m mempalace.mcp_server --palace "$PALACE_PATH"

