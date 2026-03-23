#!/usr/bin/env python3
"""Clear wiki session(s). Uses same session file as local_mcps (~/.cursor/wiki_sessions.json)."""

import json
import os
import sys
from urllib.parse import urlparse

SESSION_FILE = os.path.expanduser("~/.cursor/wiki_sessions.json")


def _load():
    try:
        with open(SESSION_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _save(sessions):
    os.makedirs(os.path.dirname(SESSION_FILE), exist_ok=True)
    with open(SESSION_FILE, "w", encoding="utf-8") as f:
        json.dump(sessions, f, indent=2, ensure_ascii=False)
    try:
        os.chmod(SESSION_FILE, 0o600)
    except Exception:
        pass


def _domain(url):
    if not url.startswith(("http://", "https://")):
        url = "http://" + url
    return urlparse(url).netloc


def clear(url: str = "") -> str:
    sessions = _load()
    if not url.strip():
        _save({})
        return "All wiki sessions cleared.\nTo login again: python -m local_mcps.cli wiki_login"
    domain = _domain(url)
    if domain in sessions:
        del sessions[domain]
        _save(sessions)
    return f"Session cleared for {domain}.\nTo login again: python -m local_mcps.cli wiki_login"


def main():
    url = sys.argv[1] if len(sys.argv) > 1 else ""
    print(clear(url))


if __name__ == "__main__":
    main()
