#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERVAL_MINUTES="${1:-10}"
LOG_FILE="$HOME/.mempalace/ingest.log"
CRON_MARKER="mempalace-memory-ingest"
CRON_CMD="*/${INTERVAL_MINUTES} * * * * bash ${SCRIPT_DIR}/ingest_all.sh >> ${LOG_FILE} 2>&1 # ${CRON_MARKER}"

mkdir -p "$HOME/.mempalace"

# Remove existing entry if any, then add new one
(crontab -l 2>/dev/null | grep -v "${CRON_MARKER}" || true; echo "${CRON_CMD}") | crontab -

echo "[mempalace-memory] Crontab timer installed: every ${INTERVAL_MINUTES}min"
echo "[mempalace-memory] Log: ${LOG_FILE}"
echo "[mempalace-memory] Check: crontab -l | grep mempalace"
