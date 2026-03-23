#!/usr/bin/env python3
"""Fetch Jira issue by URL or issue key. Uses ~/.cursor/jira_sessions.json.
Output: Markdown. Requires: requests, html2text, beautifulsoup4 (for HTML fallback)."""

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


def _issue_key_from_url(url: str) -> str:
    """Extract issue key from Jira URL (e.g. /browse/CAPS-12345 or ?key=CAPS-123)."""
    m = re.search(r"/browse/([A-Za-z][A-Za-z0-9]*-[0-9]+)", url)
    if m:
        return m.group(1)
    m = re.search(r"[?&]key=([A-Za-z][A-Za-z0-9]*-[0-9]+)", url)
    if m:
        return m.group(1)
    m = re.search(r"([A-Za-z][A-Za-z0-9]*-[0-9]+)", url)
    return m.group(1) if m else ""


def _format_issue_as_markdown(issue: dict, url: str, domain: str) -> str:
    """Turn Jira REST API issue JSON into readable markdown."""
    key = issue.get("key", "")
    fields = issue.get("fields", {})
    summary = fields.get("summary", "")
    status = (fields.get("status") or {}).get("name", "")
    issue_type = (fields.get("issuetype") or {}).get("name", "")
    assignee = (fields.get("assignee") or {}).get("displayName", "Unassigned")
    reporter = (fields.get("reporter") or {}).get("displayName", "")
    created = fields.get("created", "")
    updated = fields.get("updated", "")
    description = fields.get("description", "")
    if description and isinstance(description, dict):
        if description.get("type") == "doc" and "content" in description:
            # ADF to plain text
            def adf_to_text(blk):
                if blk.get("type") == "paragraph" and "content" in blk:
                    return "".join(adf_to_text(c) for c in blk["content"]) + "\n"
                if blk.get("type") == "text":
                    return blk.get("text", "")
                if blk.get("type") == "hardBreak":
                    return "\n"
                return ""
            description = "".join(adf_to_text(c) for c in description.get("content", []))
        else:
            description = str(description)
    elif not description:
        description = ""
    priority = (fields.get("priority") or {}).get("name", "")
    labels = fields.get("labels", [])
    components = [c.get("name", "") for c in (fields.get("components") or [])]
    links = []
    for link in (fields.get("issuelinks") or []):
        out = link.get("outwardIssue") or link.get("inwardIssue")
        if out:
            links.append(out.get("key", "") + " " + (out.get("fields", {}).get("summary", ""))[:50])
    out = [
        "# Jira Issue",
        "",
        f"**URL:** {url}",
        f"**Domain:** {domain}",
        "**Status:** Retrieved",
        "",
        "---",
        "",
        f"# {key}: {summary}",
        "",
        f"- **Type:** {issue_type}  **Status:** {status}  **Priority:** {priority}",
        f"- **Assignee:** {assignee}  **Reporter:** {reporter}",
        f"- **Created:** {created}  **Updated:** {updated}",
        f"- **Labels:** {', '.join(labels)}  **Components:** {', '.join(components)}",
        "",
        "## Description",
        "",
        description.strip() or "_No description._",
        "",
    ]
    if links:
        out.extend(["## Linked issues", ""] + [f"- {l}" for l in links] + [""])
    return "\n".join(out)


def fetch_jira(url_or_key: str, use_rest_first: bool = True) -> str:
    url_or_key = (url_or_key or "").strip()
    if not url_or_key:
        return "ERROR: Jira URL or issue key is required"

    if not url_or_key.startswith(("http://", "https://")):
        url_or_key = "http://jira.enflame.cn/browse/" + url_or_key

    url = url_or_key
    domain = _domain(url)
    sessions = _load_sessions()
    session = sessions.get(domain)
    if not session or not _session_valid(session):
        return (
            f"ERROR: No valid session found for {domain}.\n\n"
            "Please run in terminal:\n"
            "  python ~/.cursor/skills/jira_helper/jira_helper_cli.py login\n\n"
            "After logging in, try again."
        )

    cookies = session.get("cookies", {})
    headers = session.get("headers", {})
    try:
        import requests
    except ImportError:
        return "ERROR: Missing dependency. Install: pip install requests"

    parsed = urlparse(url)
    scheme = parsed.scheme or "http"
    netloc = parsed.netloc or "jira.enflame.cn"
    base = f"{scheme}://{netloc}"
    issue_key = _issue_key_from_url(url)
    if not issue_key:
        return "ERROR: Could not determine issue key from URL. Use a URL like http://jira.enflame.cn/browse/CAPS-12345"

    # 1) Try REST API
    if use_rest_first:
        api_url = urljoin(base + "/", f"rest/api/2/issue/{issue_key}")
        try:
            r = requests.get(api_url, cookies=cookies, headers=headers, timeout=30)
            if r.status_code == 401 or (r.status_code in (301, 302) and "login" in (r.headers.get("Location") or "").lower()):
                return (
                    f"ERROR: Session expired for {domain}.\n\n"
                    "Please run in terminal:\n"
                    "  python ~/.cursor/skills/jira_helper/jira_helper_cli.py login"
                )
            if r.status_code == 200:
                return _format_issue_as_markdown(r.json(), url, domain)
            if r.status_code == 404:
                pass
        except Exception as e:
            pass

    # 2) Fallback: fetch HTML browse page and convert to markdown
    browse_url = urljoin(base + "/", f"browse/{issue_key}")
    try:
        r = requests.get(browse_url, cookies=cookies, headers=headers, timeout=30, allow_redirects=True)
    except requests.exceptions.Timeout:
        return f"ERROR: Request timeout while fetching {url}"
    except requests.exceptions.ConnectionError:
        return f"ERROR: Connection failed to {domain}. Check network and URL."
    except Exception as e:
        return f"ERROR: {e}"

    if r.status_code in (401, 403) or "login" in r.url.lower():
        return (
            f"ERROR: Session expired for {domain}.\n\n"
            "Please run in terminal:\n"
            "  python ~/.cursor/skills/jira_helper/jira_helper_cli.py login"
        )
    if r.status_code != 200:
        return f"ERROR: Failed to fetch (HTTP {r.status_code}). URL: {url}"

    try:
        import html2text
    except ImportError:
        return "ERROR: Missing dependency. Install: pip install requests html2text beautifulsoup4"
    h = html2text.HTML2Text()
    h.ignore_links = h.ignore_images = h.ignore_emphasis = False
    h.body_width = 0
    markdown = h.handle(r.text)
    return (
        "# Jira Issue (HTML)\n\n**URL:** " + url + "\n**Domain:** " + domain + "\n**Status:** Retrieved\n\n---\n\n" + markdown
    )


def main():
    url_or_key = (sys.argv[1] if len(sys.argv) > 1 else "").strip()
    if not url_or_key:
        print("Usage: fetch_jira.py <jira_url_or_issue_key>", file=sys.stderr)
        sys.exit(1)
    print(fetch_jira(url_or_key))


if __name__ == "__main__":
    main()
