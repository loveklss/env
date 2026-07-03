#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
if ! bash "$SCRIPT_DIR/ensure_embedding_model.sh" >/dev/null; then
  echo "[mempalace-memory] Skip ingest: embedding model not ready."
  exit 1
fi

WS_DIR="$(workspace_dir "${1:-$PWD}")"
MODE="${2:-incremental}" # incremental | full

load_config_env

if ! source_binding "$WS_DIR"; then
  echo "[mempalace-memory] Workspace is not bound: $WS_DIR"
  exit 1
fi

SOURCE_DIR="${CURSOR_TRANSCRIPT_DIR:-$CURSOR_PROJECTS_ROOT/$WORKSPACE_KEY/agent-transcripts}"
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "[mempalace-memory] Transcript dir not found: $SOURCE_DIR"
  exit 0
fi

RUN_ROOT="$HOME/.mempalace/ingest_runs/$WORKSPACE_KEY"
STATE_FILE="$HOME/.mempalace/ingest_state/$WORKSPACE_KEY.last_epoch"
mkdir -p "$RUN_ROOT" "$(dirname "$STATE_FILE")"

LAST_EPOCH=0
if [[ "$MODE" == "incremental" && -f "$STATE_FILE" ]]; then
  LAST_EPOCH="$(tr -d ' \t\r\n' < "$STATE_FILE")"
fi

RUN_DIR="$RUN_ROOT/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"

COPIED="$(
python3 - "$SOURCE_DIR" "$LAST_EPOCH" "$RUN_DIR" "$MODE" <<'PY'
import os
import shutil
import sys
from pathlib import Path

source = Path(sys.argv[1])
last_epoch = int(sys.argv[2])
run_dir = Path(sys.argv[3])
mode = sys.argv[4]
allowed = {".jsonl", ".md", ".txt"}
count = 0

for root, _, files in os.walk(source):
    for name in files:
        src = Path(root) / name
        if src.suffix.lower() not in allowed:
            continue
        if mode == "incremental" and int(src.stat().st_mtime) <= last_epoch:
            continue
        dst = run_dir / src.name
        if dst.exists():
            stem = dst.stem
            suffix = dst.suffix
            idx = 1
            while (run_dir / f"{stem}-{idx}{suffix}").exists():
                idx += 1
            dst = run_dir / f"{stem}-{idx}{suffix}"
        shutil.copy2(src, dst)
        count += 1
print(count)
PY
)"

if [[ "$COPIED" == "0" ]]; then
  rmdir "$RUN_DIR" >/dev/null 2>&1 || true
  echo "[mempalace-memory] No transcript files to ingest: $WS_DIR"
  exit 0
fi

WING_NAME="wing_${FAMILY}"
LOG_DIR="$STATE_DIR/logs"
mkdir -p "$LOG_DIR"
ERR_LOG="$LOG_DIR/ingest-${WORKSPACE_KEY}.log"

if mempalace --palace "$PALACE_PATH" mine "$RUN_DIR" --mode convos --wing "$WING_NAME" --agent cursor >/dev/null 2>"$ERR_LOG"; then
  date +%s > "$STATE_FILE"
  echo "[mempalace-memory] Ingested $COPIED files -> $PALACE_PATH ($WING_NAME)"
else
  if rg -q "ConnectTimeout|timed out" "$ERR_LOG"; then
    echo "[mempalace-memory] Ingest failed: model download/network timeout."
    echo "[mempalace-memory] Check network, then rerun ingest."
  else
    echo "[mempalace-memory] Ingest failed. Error log: $ERR_LOG"
  fi
  exit 1
fi

