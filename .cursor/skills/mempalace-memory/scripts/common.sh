#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${MEMPALACE_MEMORY_CONFIG:-$HOME/.config/mempalace-memory/config.json}"
STATE_DIR="$HOME/.config/mempalace-memory"
BINDINGS_DIR="$STATE_DIR/bindings"

workspace_dir() {
  local dir="${1:-$PWD}"
  realpath "$dir"
}

workspace_key() {
  local dir
  dir="$(workspace_dir "$1")"
  python3 - "$dir" <<'PY'
import sys
p = sys.argv[1].lstrip("/")
print(p.replace("/", "-").replace(".", "-").replace("_", "-"))
PY
}

load_config_env() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[mempalace-memory] Missing config: $CONFIG_FILE" >&2
    return 1
  fi

  eval "$(
    python3 - "$CONFIG_FILE" <<'PY'
import json
import pathlib
import sys

cfg = json.loads(pathlib.Path(sys.argv[1]).expanduser().read_text())
palace_root = str(pathlib.Path(cfg.get("palace_root", "~/.mempalace/palaces")).expanduser())
cursor_root = str(pathlib.Path(cfg.get("cursor_projects_root", "~/.cursor/projects")).expanduser())
default_family = cfg.get("default_family", "general")
model = cfg.get("embedding_model", {})
cache_dir = str(pathlib.Path(model.get("cache_dir", "~/.cache/chroma/onnx_models/all-MiniLM-L6-v2")).expanduser())
archive_name = model.get("archive_name", "onnx.tar.gz")
local_archive_path = model.get("local_archive_path", "")
retry_cooldown_sec = int(model.get("retry_cooldown_sec", 21600))
if local_archive_path:
    local_archive_path = str(pathlib.Path(local_archive_path).expanduser())
download_urls = model.get("download_urls", [])
download_urls_joined = " ".join(download_urls)
print(f"PALACE_ROOT='{palace_root}'")
print(f"CURSOR_PROJECTS_ROOT='{cursor_root}'")
print(f"DEFAULT_FAMILY='{default_family}'")
print(f"EMBED_CACHE_DIR='{cache_dir}'")
print(f"EMBED_ARCHIVE_NAME='{archive_name}'")
print(f"EMBED_LOCAL_ARCHIVE='{local_archive_path}'")
print(f"EMBED_RETRY_COOLDOWN_SEC='{retry_cooldown_sec}'")
print(f"EMBED_DOWNLOAD_URLS='{download_urls_joined}'")
PY
  )"
}

detect_family() {
  local ws_dir
  ws_dir="$(workspace_dir "$1")"
  local family_file="$ws_dir/.mempalace-family"

  if [[ -f "$family_file" ]]; then
    local v
    v="$(tr -d ' \t\r\n' < "$family_file")"
    if [[ -n "$v" ]]; then
      echo "$v"
      return 0
    fi
  fi

  python3 - "$CONFIG_FILE" "$ws_dir" <<'PY'
import json
import pathlib
import re
import sys

cfg = json.loads(pathlib.Path(sys.argv[1]).expanduser().read_text())
name = pathlib.Path(sys.argv[2]).name.lower()
family = cfg.get("default_family", "general")
for rule in cfg.get("family_rules", []):
    pattern = rule.get("folder_name_regex", "")
    if pattern and re.search(pattern, name):
        family = rule["family"]
        break
print(family)
PY
}

binding_file() {
  local ws_key
  ws_key="$(workspace_key "$1")"
  mkdir -p "$BINDINGS_DIR"
  echo "$BINDINGS_DIR/$ws_key.env"
}

write_binding() {
  local ws_dir="$1"
  local family="$2"
  local palace="$3"
  local ws_key
  ws_key="$(workspace_key "$ws_dir")"
  local bind_file
  bind_file="$(binding_file "$ws_dir")"
  cat > "$bind_file" <<EOF
WORKSPACE_DIR="$ws_dir"
WORKSPACE_KEY="$ws_key"
FAMILY="$family"
PALACE_PATH="$palace"
CURSOR_PROJECTS_ROOT="$CURSOR_PROJECTS_ROOT"
EOF
}

source_binding() {
  local ws_dir="$1"
  local bind_file
  bind_file="$(binding_file "$ws_dir")"
  if [[ ! -f "$bind_file" ]]; then
    return 1
  fi
  source "$bind_file"
}

ensure_mcp_config() {
  local ws_dir="$1"
  local family="$2"
  mkdir -p "$ws_dir/.cursor"
  cat > "$ws_dir/.cursor/mcp.json" <<EOF
{
  "mcpServers": {
    "mempalace-${family}": {
      "command": "bash",
      "args": [
        "$HOME/.cursor/skills/mempalace-memory/scripts/run_mcp_server.sh",
        "$ws_dir"
      ]
    }
  }
}
EOF
}

