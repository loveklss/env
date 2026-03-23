#!/usr/bin/env python3
"""Standalone CLI entry point for jira_helper."""

import sys
import os

script_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "scripts")
sys.path.insert(0, script_dir)


def show_usage():
    script_path = os.path.abspath(__file__)
    print("Jira Helper CLI - Manage Jira authentication and sessions")
    print()
    print("Usage:")
    print(f"  python {script_path} login [URL] [USERNAME]")
    print(f"  python {script_path} logout [URL|--all]")
    print(f"  python {script_path} info [URL]")
    print()
    print("Examples:")
    print(f"  python {script_path} login")
    print(f"  python {script_path} login http://jira.enflame.cn")
    print(f"  python {script_path} logout --all")
    print(f"  python {script_path} info http://jira.enflame.cn")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        show_usage()
        sys.exit(1)
    from auth_cli import main as auth_main
    auth_main(sys.argv[1:])
