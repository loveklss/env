---
name: scp-to-remote
description: Copies project files to a remote host via SCP. Use when the user drags files into the chat, or describes which files to copy (by name, path, or pattern such as "all .go files" or "files in pkg/"), and asks to copy them to a remote machine, server, or another host. Handles default host, user, and directory via script config.
---

# SCP to Remote

Copy local project files or directories to a remote host using SCP. The agent runs a script that uses configurable default host, username, and remote directory; credentials (password or SSH key) are set in the script.

## When to Use

- User attaches or drags files into the chat and asks to copy them to a remote host.
- User describes which files to copy (e.g. by name, path, extension, or directory) and asks to copy to a remote/server/another machine.
- User mentions "scp", "copy to remote", "copy to server", or "deploy these files" in combination with file selection.

## Configuration (Required Before First Use)

All defaults are in the script. The user must edit once:

**File:** `~/.cursor/skills/scp-to-remote/scripts/scp-to-remote.sh`

At the top, set:

- `SCP_USER`: remote username
- `SCP_HOST`: remote host (IP or hostname)
- `SCP_REMOTE_DIR`: default remote directory (e.g. `/home/user/workspace`)
- Auth (one of):
  - `SSH_KEY_PATH`: path to SSH private key (recommended); leave `SCP_PASSWORD` empty
  - `SCP_PASSWORD`: password for SCP (requires `sshpass` installed); leave `SSH_KEY_PATH` empty if using this

Security: the script lives in the user's home directory; do not share or commit it if it contains a real password. Prefer `SSH_KEY_PATH`. If using password, run `chmod 600` on the script. Ensure the script is executable: `chmod +x ~/.cursor/skills/scp-to-remote/scripts/scp-to-remote.sh`.

Dependency: if using `SCP_PASSWORD`, the system must have `sshpass` (e.g. `apt install sshpass` or `yum install sshpass`). Key-based auth does not require sshpass.

## Workflow

1. **Resolve file list**
   - If the user attached or dragged files: extract their paths from context (relative to project root or absolute).
   - If the user only described files: resolve in the **current project root** by name, path, extension, or pattern (e.g. `find`, `git ls-files`, or globs). If ambiguous, confirm with the user.
   - Support both files and directories; the script will use `scp -r` when any path is a directory.

2. **Choose destination**
   - If the user specified a destination (e.g. `user@host:/path`), use it.
   - Otherwise use the script’s default (no need to pass a destination argument).

3. **Run the script**
   - From the **current project root**, run:
     `bash ~/.cursor/skills/scp-to-remote/scripts/scp-to-remote.sh <file1> [file2 ...] [user@host:path]`
   - Pass only file/directory paths when using the default destination. To override, append one argument in the form `user@host:path`.
   - Paths are relative to the current working directory (project root).

4. **Report result**
   - On success, report that the copy completed.
   - On failure, report the script’s stderr and suggest checking: script config (host, user, default dir, key/password), network, and remote permissions.

## Examples

**Example 1 – Copy by description to default destination**

User: "Copy all .go files in pkg/ to the remote server."

- Resolve files (e.g. `find pkg -name '*.go'` or list them).
- Run: `bash ~/.cursor/skills/scp-to-remote/scripts/scp-to-remote.sh pkg/foo.go pkg/bar.go ...` (no destination argument).

**Example 2 – Copy attached files to custom destination**

User drags `src/a.go` and `src/b.go` and says: "Copy these to user@host.example.com:/tmp."

- Run: `bash ~/.cursor/skills/scp-to-remote/scripts/scp-to-remote.sh src/a.go src/b.go user@host.example.com:/tmp`

**Example 3 – Copy a directory**

User: "Copy the entire `configs` directory to the default remote."

- Run: `bash ~/.cursor/skills/scp-to-remote/scripts/scp-to-remote.sh configs` (script uses `-r` for directories).
