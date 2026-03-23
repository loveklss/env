#!/usr/bin/env python3
"""Download a Jira attachment using stored session. Usage: python download_attachment.py <attachment_url> [output_path]"""
import json
import os
import sys
import requests
from urllib.parse import urlparse

SESSION_FILE = os.path.expanduser("~/.cursor/jira_sessions.json")

def main():
    if len(sys.argv) < 2:
        print("Usage: download_attachment.py <attachment_url> [output_path]", file=sys.stderr)
        sys.exit(1)
    url = sys.argv[1].strip()
    out_path = sys.argv[2].strip() if len(sys.argv) > 2 else None
    if not out_path:
        out_path = os.path.basename(urlparse(url).path) or "attachment.bin"

    base = "http://jira.enflame.cn"
    domain = "jira.enflame.cn"
    try:
        with open(SESSION_FILE, "r", encoding="utf-8") as f:
            sessions = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        print("ERROR: No valid session. Run jira_helper_cli.py login first.", file=sys.stderr)
        sys.exit(1)
    session = sessions.get(domain)
    if not session:
        print("ERROR: No session for", domain, file=sys.stderr)
        sys.exit(1)
    cookies = session.get("cookies", {})
    headers = session.get("headers", {})

    r = requests.get(url, cookies=cookies, headers=headers, timeout=30)
    r.raise_for_status()
    with open(out_path, "wb") as f:
        f.write(r.content)
    print(out_path)

if __name__ == "__main__":
    main()
