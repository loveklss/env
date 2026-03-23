#!/bin/bash
# Copy local files/directories to remote host via SCP.
# Edit the variables below before first use. Script is in personal dir; do not share if password is set.

# --- Config (edit these) ---
SCP_USER="qhu"
SCP_HOST="10.168.101.37"
SCP_REMOTE_DIR="/home/qhu/enflame"
# Auth: set SSH_KEY_PATH for key-based auth, or SCP_PASSWORD for password (requires sshpass).
SSH_KEY_PATH="$HOME/.ssh/id_rsa"
SCP_PASSWORD=""

# --- Parse args: file1 [file2 ...] [user@host:path] ---
declare -a FILES=()
DEST=""
while [ $# -gt 0 ]; do
    if [[ "$1" =~ @.*: ]]; then
        DEST="$1"
    else
        FILES+=("$1")
    fi
    shift
done

if [ ${#FILES[@]} -eq 0 ]; then
    echo "Usage: $0 file1 [file2 ...] [user@host:path]" >&2
    exit 1
fi

if [ -z "$DEST" ]; then
    if [ -z "$SCP_USER" ] || [ -z "$SCP_HOST" ] || [ -z "$SCP_REMOTE_DIR" ]; then
        echo "No destination given and default not configured. Set SCP_USER, SCP_HOST, SCP_REMOTE_DIR in script." >&2
        exit 1
    fi
    DEST="$SCP_USER@$SCP_HOST:$SCP_REMOTE_DIR"
fi

for f in "${FILES[@]}"; do
    if [ ! -e "$f" ]; then
        echo "No such file or directory: $f" >&2
        exit 1
    fi
done

SCP_OPTS=()
for f in "${FILES[@]}"; do
    if [ -d "$f" ]; then
        SCP_OPTS+=(-r)
        break
    fi
done
[ -n "$SSH_KEY_PATH" ] && SCP_OPTS+=(-i "$SSH_KEY_PATH")

run_scp() {
    if [ -n "$SSH_KEY_PATH" ]; then
        scp "${SCP_OPTS[@]}" "${FILES[@]}" "$DEST"
    elif [ -n "$SCP_PASSWORD" ]; then
        sshpass -p "$SCP_PASSWORD" scp "${SCP_OPTS[@]}" "${FILES[@]}" "$DEST"
    else
        scp "${SCP_OPTS[@]}" "${FILES[@]}" "$DEST"
    fi
}

run_scp
exit $?
