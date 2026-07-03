#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config_env

if [[ ! -d "$BINDINGS_DIR" ]]; then
  echo "[mempalace-memory] No bindings found."
  exit 0
fi

while IFS= read -r bind_file; do
  source "$bind_file"
  bash "$SCRIPT_DIR/ingest.sh" "$WORKSPACE_DIR" "incremental" || true
done < <(rg --files "$BINDINGS_DIR" -g "*.env")

