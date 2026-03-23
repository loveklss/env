#!/usr/bin/env python3
"""Jira login command - standalone entry point for skill."""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from auth_cli import main

if __name__ == "__main__":
    main(["login"] + sys.argv[1:])
