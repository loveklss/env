#!/usr/bin/env python3
"""Print Jira session info. Uses ~/.cursor/jira_sessions.json."""

import json
import os
import sys
from datetime import datetime, timedelta
from urllib.parse import urlparse

SESSION_FILE = os.path.expanduser("~/.cursor/jira_sessions.json")


def _load():
    try:
        with open(SESSION_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _domain(url):
    if not url.startswith(("http://", "https://")):
        url = "http://" + url
    return urlparse(url).netloc


def session_info(url: str) -> str:
    if not url.strip():
        return "ERROR: URL is required"
    domain = _domain(url)
    sessions = _load()
    session = sessions.get(domain)
    if not session:
        return (
            f"No session found for {domain}.\n\n"
            "To login, run in terminal:\n"
            "  python ~/.cursor/skills/jira_helper/jira_helper_cli.py login"
        )
    try:
        created = datetime.fromisoformat(session["created_at"])
        hours = session.get("expires_hours", 24)
        expires = created + timedelta(hours=hours)
        valid = datetime.now() < expires
        return (
            f"Session for {domain}:\n"
            f"  Created: {created.strftime('%Y-%m-%d %H:%M:%S')}\n"
            f"  Expires: {expires.strftime('%Y-%m-%d %H:%M:%S')}\n"
            f"  Status: {'Valid' if valid else 'Expired'}"
        )
    except (ValueError, KeyError):
        return "Session data corrupted"


def main():
    url = (sys.argv[1] if len(sys.argv) > 1 else "").strip()
    if not url:
        print("Usage: jira_session_info.py <url>", file=sys.stderr)
        sys.exit(1)
    print(session_info(url))


if __name__ == "__main__":
    main()
