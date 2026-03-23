#!/usr/bin/env python3
"""Fetch Jira issue comments. Uses ~/.cursor/jira_sessions.json.
Usage: python fetch_jira_comments.py <issue_url_or_key> [--attachments]
Output: Markdown list of comments; with --attachments also list attachment URLs."""

import json
import os
import re
import sys
from datetime import datetime, timedelta
from urllib.parse import urlparse, urljoin

SESSION_FILE = os.path.expanduser("~/.cursor/jira_sessions.json")


def _load_sessions():
    try:
        with open(SESSION_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _domain(url):
    if not url.startswith(("http://", "https://")):
        url = "http://" + url
    return urlparse(url).netloc


def _session_valid(session):
    try:
        created = datetime.fromisoformat(session["created_at"])
        hours = session.get("expires_hours", 24)
        return datetime.now() < created + timedelta(hours=hours)
    except (ValueError, KeyError):
        return False


def _issue_key_from_url(url_or_key: str) -> str:
    if re.match(r"^[A-Za-z][A-Za-z0-9]*-[0-9]+$", url_or_key.strip()):
        return url_or_key.strip()
    url = url_or_key if url_or_key.startswith(("http://", "https://")) else "http://jira.enflame.cn/browse/" + url_or_key
    m = re.search(r"/browse/([A-Za-z][A-Za-z0-9]*-[0-9]+)", url)
    if m:
        return m.group(1)
    m = re.search(r"([A-Za-z][A-Za-z0-9]*-[0-9]+)", url)
    return m.group(1) if m else ""


def _adf_to_text(blk):
    """Convert ADF node to plain text."""
    if blk.get("type") == "paragraph" and "content" in blk:
        return "".join(_adf_to_text(c) for c in blk["content"]) + "\n"
    if blk.get("type") == "text":
        return blk.get("text", "")
    if blk.get("type") == "hardBreak":
        return "\n"
    if blk.get("type") == "mention":
        return blk.get("attrs", {}).get("text", "")
    return ""


def fetch_comments(url_or_key: str, include_attachment_info: bool = False) -> str:
    url_or_key = (url_or_key or "").strip()
    if not url_or_key:
        return "ERROR: Issue URL or key is required"

    if not url_or_key.startswith(("http://", "https://")):
        base_url = "http://jira.enflame.cn"
        issue_ref = url_or_key
    else:
        parsed = urlparse(url_or_key)
        base_url = f"{parsed.scheme}://{parsed.netloc}"
        issue_ref = url_or_key

    domain = _domain(base_url)
    sessions = _load_sessions()
    session = sessions.get(domain)
    if not session or not _session_valid(session):
        return (
            f"ERROR: No valid session for {domain}.\n\n"
            "Run: python ~/.cursor/skills/jira_helper/jira_helper_cli.py login"
        )

    issue_key = _issue_key_from_url(issue_ref)
    if not issue_key:
        return "ERROR: Could not parse issue key from URL or key."

    try:
        import requests
    except ImportError:
        return "ERROR: pip install requests"

    cookies = session.get("cookies", {})
    headers = session.get("headers", {})
    base = base_url.rstrip("/")

    # GET comments
    comments_url = urljoin(base + "/", f"rest/api/2/issue/{issue_key}/comment")
    r = requests.get(comments_url, cookies=cookies, headers=headers, timeout=30)
    if r.status_code == 401 or (r.status_code in (301, 302) and "login" in (r.headers.get("Location") or "").lower()):
        return f"ERROR: Session expired for {domain}. Run jira_helper_cli.py login"
    if r.status_code != 200:
        return f"ERROR: Failed to fetch comments (HTTP {r.status_code})"

    data = r.json()
    comments = data.get("comments", [])

    lines = [
        f"# Jira Comments: {issue_key}",
        "",
        f"**URL:** {base_url}/browse/{issue_key}",
        f"**Total comments:** {len(comments)}",
        "",
        "---",
        "",
    ]

    for i, c in enumerate(comments, 1):
        author = (c.get("author") or {}).get("displayName", "")
        created = c.get("created", "")
        body = c.get("body")
        if isinstance(body, dict) and body.get("type") == "doc" and "content" in body:
            text = "".join(_adf_to_text(x) for x in body.get("content", []))
        else:
            text = str(body) if body else ""
        lines.append(f"## Comment {i}")
        lines.append(f"- **Author:** {author}  **Created:** {created}")
        lines.append("")
        lines.append(text.strip() or "_（无正文，可能仅含图片/附件）_")
        lines.append("")

    if include_attachment_info and comments:
        # Optionally fetch issue attachments (comment images often appear as issue attachments)
        issue_url = urljoin(base + "/", f"rest/api/2/issue/{issue_key}?fields=attachment")
        r2 = requests.get(issue_url, cookies=cookies, headers=headers, timeout=30)
        if r2.status_code == 200:
            atts = (r2.json().get("fields") or {}).get("attachment", [])
            if atts:
                lines.append("---")
                lines.append("## Attachments")
                lines.append("")
                for a in atts:
                    lines.append(f"- **{a.get('filename', '')}** ({a.get('size', 0)} bytes)")
                    lines.append(f"  {a.get('content', '')}")
                lines.append("")

    return "\n".join(lines).strip() + "\n"


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    include_att = "--attachments" in sys.argv
    url_or_key = args[0] if args else ""
    if not url_or_key:
        print("Usage: fetch_jira_comments.py <issue_url_or_key> [--attachments]", file=sys.stderr)
        sys.exit(1)
    print(fetch_comments(url_or_key, include_attachment_info=include_att))


if __name__ == "__main__":
    main()
