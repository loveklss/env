#!/usr/bin/env bash
# recall.sh - Search mempalace palace for past conversation content.
# Usage:
#   recall.sh [workspace_path] <keyword> [extra_keywords...]
#
# If the first argument starts with '/', it is treated as the workspace path.
# Otherwise the current working directory is used.
# All remaining arguments are treated as keywords (combined as regex OR for rg).
#
# Example:
#   recall.sh /home/stephen.hu/ws/gitee/caps "MSI-X" "MSIX" "msix"
#   recall.sh "VGP" "vgp_mgr" "scorpio_vgp"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ── Parse arguments ──────────────────────────────────────────────────────────
if [[ "${1:-}" == /* ]]; then
    WS_DIR="$(workspace_dir "$1")"
    shift
else
    WS_DIR="$(workspace_dir "$PWD")"
fi

if [[ $# -eq 0 ]]; then
    echo "Usage: recall.sh [workspace] <keyword> [extra_keywords...]" >&2
    exit 1
fi

KEYWORDS=("$@")
PRIMARY_KW="${KEYWORDS[0]}"

# rg OR pattern: "kw1|kw2|kw3"
RG_PATTERN=$(
    printf '%s' "${KEYWORDS[0]}"
    for k in "${KEYWORDS[@]:1}"; do printf '|%s' "$k"; done
)

# ── Resolve palace (no bind/ingest overhead) ─────────────────────────────────
PALACE_HINT="$WS_DIR/.mempalace-palace"
if [[ ! -f "$PALACE_HINT" ]]; then
    echo "[recall] ERROR: No palace hint at $PALACE_HINT" >&2
    echo "[recall] Run: bash ~/.cursor/skills/mempalace-memory/scripts/bind.sh \"$WS_DIR\"" >&2
    exit 1
fi
PALACE=$(tr -d '\r\n' < "$PALACE_HINT")

# ── Resolve transcripts directory ────────────────────────────────────────────
WS_KEY=$(python3 - "$WS_DIR" <<'PY'
import sys
p = sys.argv[1].lstrip("/")
print(p.replace("/", "-").replace(".", "-").replace("_", "-"))
PY
)
TDIR="$HOME/.cursor/projects/$WS_KEY/agent-transcripts"

# ── Step 1: Semantic recall ───────────────────────────────────────────────────
echo "=== Semantic Recall: \"$PRIMARY_KW\" ==="
mempalace --palace "$PALACE" search "\"$PRIMARY_KW\"" --results 5 2>/dev/null || true

# ── Step 2: Exact-match UUID list ────────────────────────────────────────────
echo ""
echo "=== Exact Match UUIDs (rg pattern: $RG_PATTERN) ==="
if [[ -d "$TDIR" ]]; then
    rg -rl "$RG_PATTERN" "$TDIR" 2>/dev/null \
        | sed 's|.*/\([a-f0-9-]\{36\}\)/.*|\1|' \
        | sort -u \
    || echo "(no exact matches found)"
else
    echo "(transcripts directory not found: $TDIR)"
fi
