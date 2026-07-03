#!/usr/bin/env bash
set -euo pipefail

CRON_MARKER="mempalace-memory-ingest"

if crontab -l 2>/dev/null | grep -q "${CRON_MARKER}"; then
    (crontab -l 2>/dev/null | grep -v "${CRON_MARKER}") | crontab -
    echo "[mempalace-memory] Crontab timer removed."
else
    echo "[mempalace-memory] No crontab timer found, nothing to remove."
fi
