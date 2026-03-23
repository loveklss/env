#!/usr/bin/env python3
"""Command-line authentication for Jira login."""

import sys
import os
import getpass
from typing import Optional

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from session_manager import SessionManager
from authenticator import Authenticator


def login_command(url: Optional[str] = None, username: Optional[str] = None):
    if not url:
        default_url = "http://jira.enflame.cn"
        url_input = input(f"Enter Jira URL [{default_url}]: ").strip()
        url = url_input or default_url
    if not username:
        username = input("Username: ").strip()
        if not username:
            print("ERROR: Username is required")
            sys.exit(1)
    password = getpass.getpass("Password: ")
    if not password:
        print("ERROR: Password is required")
        sys.exit(1)

    auth = Authenticator()
    session_mgr = SessionManager()
    print(f"\nAuthenticating with {url}...")
    try:
        cookies, headers = auth.login(url, username, password)
        session_mgr.save_session(url, cookies, headers)
        from urllib.parse import urlparse
        domain = urlparse(url).netloc if url.startswith(("http://", "https://")) else url
        print(f"✓ Login successful! Session saved for {domain}")
        print(f"✓ Session will expire in 24 hours")
    except Exception as e:
        print(f"✗ Login failed: {str(e)}")
        sys.exit(1)


def logout_command(url: Optional[str] = None, clear_all: bool = False):
    session_mgr = SessionManager()
    if clear_all:
        session_mgr.clear_session(None)
        print("✓ All Jira sessions cleared")
        return
    if not url:
        url_input = input("Enter Jira URL to clear (or 'all' to clear all): ").strip()
        if url_input.lower() == "all":
            session_mgr.clear_session(None)
            print("✓ All Jira sessions cleared")
            return
        url = url_input
    if not url:
        print("ERROR: URL is required")
        sys.exit(1)
    from urllib.parse import urlparse
    domain = urlparse(url).netloc if url.startswith(("http://", "https://")) else url
    session_mgr.clear_session(url)
    print(f"✓ Session cleared for {domain}")


def info_command(url: Optional[str] = None):
    if not url:
        url = input("Enter Jira URL: ").strip()
    if not url:
        print("ERROR: URL is required")
        sys.exit(1)
    session_mgr = SessionManager()
    info = session_mgr.get_session_info(url)
    if info:
        print(info)
    else:
        from urllib.parse import urlparse
        domain = urlparse(url).netloc if url.startswith(("http://", "https://")) else url
        print(f"No session found for {domain}")


def main(args=None):
    if args is None:
        args = sys.argv[1:]
    if not args:
        print("Usage:")
        print("  Login:   python auth_cli.py login [URL] [USERNAME]")
        print("  Logout:  python auth_cli.py logout [URL|--all]")
        print("  Info:    python auth_cli.py info [URL]")
        sys.exit(1)
    cmd = args[0]
    if cmd == "login":
        login_command(args[1] if len(args) > 1 else None, args[2] if len(args) > 2 else None)
    elif cmd == "logout":
        if len(args) > 1 and args[1] == "--all":
            logout_command(clear_all=True)
        else:
            logout_command(args[1] if len(args) > 1 else None)
    elif cmd == "info":
        info_command(args[1] if len(args) > 1 else None)
    else:
        print(f"Unknown command: {cmd}. Use: login, logout, info")
        sys.exit(1)


if __name__ == "__main__":
    main()
