#!/usr/bin/env python3
"""Fetch internal wiki page. Uses same session file as local_mcps (~/.cursor/wiki_sessions.json).
Requires: requests, html2text, beautifulsoup4. Run from Skill when MCP is unavailable."""

import hashlib
import json
import os
import re
import sys
from datetime import datetime, timedelta
from urllib.parse import urlparse, urljoin

SESSION_FILE = os.path.expanduser("~/.cursor/wiki_sessions.json")


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


def _extract_page_id(url):
    m = re.search(r"pageId=(\d+)", url)
    return m.group(1) if m else hashlib.md5(url.encode()).hexdigest()[:12]


def _download_images(html_content, base_url, page_id, cookies, headers):
    try:
        from bs4 import BeautifulSoup
        import requests
    except ImportError:
        return []
    soup = BeautifulSoup(html_content, "html.parser")
    images = soup.find_all("img")
    image_dir = f"/tmp/wiki_images/{page_id}"
    os.makedirs(image_dir, exist_ok=True)
    result = []
    max_images, max_size = 20, 10 * 1024 * 1024
    for idx, img in enumerate(images[:max_images]):
        src = img.get("src")
        if not src or not any(p in src for p in ["/download/", "/attachments/", "/images/"]):
            continue
        if src.startswith(("http://", "https://")) and base_url not in src:
            continue
        full_url = base_url.rstrip("/") + src if src.startswith("/") else urljoin(base_url, src)
        try:
            r = requests.get(full_url, cookies=cookies, headers=headers, timeout=10, stream=True)
            if r.status_code != 200:
                continue
            data = r.content
            if len(data) > max_size:
                continue
            name = os.path.basename(src.split("?")[0])
            if not name or "." not in name:
                name = f"image_{idx}.png"
            path = os.path.join(image_dir, name)
            with open(path, "wb") as f:
                f.write(data)
            result.append({"name": name, "path": path, "size": len(data), "url": full_url, "original_src": src})
        except Exception:
            continue
    return result


def fetch_wiki(url: str, download_images: bool = True) -> str:
    if not url.strip():
        return "ERROR: URL is required"
    if not url.startswith(("http://", "https://")):
        url = "http://" + url
    domain = _domain(url)
    sessions = _load_sessions()
    session = sessions.get(domain)
    if not session or not _session_valid(session):
        return (
            f"ERROR: No valid session found for {domain}.\n\n"
            "Please run in terminal: python -m local_mcps.cli wiki_login\n\n"
            "After logging in, try again."
        )
    cookies = session.get("cookies", {})
    headers = session.get("headers", {})
    try:
        import requests
        import html2text
    except ImportError as e:
        return f"ERROR: Missing dependency: {e}. Install: pip install requests html2text beautifulsoup4"
    try:
        r = requests.get(url, cookies=cookies, headers=headers, timeout=30, allow_redirects=True)
    except requests.exceptions.Timeout:
        return f"ERROR: Request timeout while fetching {url}"
    except requests.exceptions.ConnectionError:
        return f"ERROR: Connection failed to {domain}. Check network and URL."
    except Exception as e:
        return f"ERROR: {e}"
    if r.status_code in (401, 403) or "login" in r.url.lower():
        return (
            f"ERROR: Session expired for {domain}.\n\n"
            "Please run: python -m local_mcps.cli wiki_login"
        )
    if r.status_code != 200:
        return f"ERROR: Failed to fetch (HTTP {r.status_code}). URL: {url}"
    downloaded = []
    if download_images:
        page_id = _extract_page_id(url)
        base = f"https://{domain}" if url.startswith("https://") else f"http://{domain}"
        downloaded = _download_images(r.text, base, page_id, cookies, headers)
    h = html2text.HTML2Text()
    h.ignore_links = h.ignore_images = h.ignore_emphasis = False
    h.body_width = 0
    markdown = h.handle(r.text)
    for info in downloaded:
        markdown = markdown.replace(f"]({info['original_src']})", f"]({info['path']})")
        if info["original_src"].startswith("/"):
            full = f"http://{domain}{info['original_src']}"
            markdown = markdown.replace(f"]({full})", f"]({info['path']})")
    out = "# Wiki Page Content\n\n**URL:** " + url + "\n**Domain:** " + domain + "\n**Status:** Retrieved\n"
    if downloaded:
        out += f"**Images Downloaded:** {len(downloaded)}\n"
    out += "\n---\n\n" + markdown
    if downloaded:
        out += "\n\n---\n\n## Downloaded Images\n\n"
        for info in downloaded:
            out += f"- **{info['name']}**: `{info['path']}`\n"
    return out


def main():
    url = (sys.argv[1] if len(sys.argv) > 1 else "").strip()
    no_images = "--no-images" in sys.argv
    if not url:
        print("Usage: fetch_wiki.py <url> [--no-images]", file=sys.stderr)
        sys.exit(1)
    print(fetch_wiki(url, download_images=not no_images))


if __name__ == "__main__":
    main()
