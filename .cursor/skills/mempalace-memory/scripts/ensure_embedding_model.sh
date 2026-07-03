#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config_env

MODEL_DIR="$EMBED_CACHE_DIR/onnx"
ARCHIVE_PATH="$EMBED_CACHE_DIR/$EMBED_ARCHIVE_NAME"
FAIL_MARKER="$STATE_DIR/embedding_download_failed_at"
mkdir -p "$EMBED_CACHE_DIR"

has_model_files() {
  local required=(
    "config.json"
    "model.onnx"
    "special_tokens_map.json"
    "tokenizer_config.json"
    "tokenizer.json"
    "vocab.txt"
  )
  local f
  for f in "${required[@]}"; do
    if [[ ! -f "$MODEL_DIR/$f" ]]; then
      return 1
    fi
  done
  return 0
}

extract_archive_if_possible() {
  if [[ -f "$ARCHIVE_PATH" ]]; then
    tar -xzf "$ARCHIVE_PATH" -C "$EMBED_CACHE_DIR"
  fi
}

download_from_urls() {
  local url
  for url in $EMBED_DOWNLOAD_URLS; do
    if command -v curl >/dev/null 2>&1; then
      if curl -L --fail --connect-timeout 10 --max-time 30 -o "$ARCHIVE_PATH" "$url"; then
        return 0
      fi
    fi
    if command -v wget >/dev/null 2>&1; then
      if wget --tries=1 --timeout=15 -O "$ARCHIVE_PATH" "$url"; then
        return 0
      fi
    fi
  done
  return 1
}

if has_model_files; then
  rm -f "$FAIL_MARKER"
  echo "[mempalace-memory] Embedding model ready: $MODEL_DIR"
  exit 0
fi

if [[ -n "$EMBED_LOCAL_ARCHIVE" && -f "$EMBED_LOCAL_ARCHIVE" ]]; then
  cp -f "$EMBED_LOCAL_ARCHIVE" "$ARCHIVE_PATH"
  extract_archive_if_possible
fi

if has_model_files; then
  rm -f "$FAIL_MARKER"
  echo "[mempalace-memory] Embedding model loaded from local archive."
  exit 0
fi

if [[ -f "$FAIL_MARKER" ]]; then
  NOW_EPOCH="$(date +%s)"
  LAST_FAIL="$(tr -d ' \t\r\n' < "$FAIL_MARKER")"
  if [[ -n "$LAST_FAIL" ]]; then
    AGE="$((NOW_EPOCH - LAST_FAIL))"
    if [[ "$AGE" -lt "$EMBED_RETRY_COOLDOWN_SEC" ]]; then
      echo "[mempalace-memory] Skip model download retry (cooldown ${EMBED_RETRY_COOLDOWN_SEC}s)."
      exit 1
    fi
  fi
fi

if download_from_urls; then
  extract_archive_if_possible
fi

if has_model_files; then
  rm -f "$FAIL_MARKER"
  echo "[mempalace-memory] Embedding model downloaded and extracted."
  exit 0
fi

date +%s > "$FAIL_MARKER"
echo "[mempalace-memory] Embedding model unavailable."
echo "[mempalace-memory] Provide local archive via config.embedding_model.local_archive_path"
echo "[mempalace-memory] or set accessible config.embedding_model.download_urls"
exit 1

