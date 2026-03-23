---
name: wiki-helper
description: Fetches internal wiki (Confluence) page content, clears wiki session, or shows session info. Use when the user asks to open/fetch/summarize an internal wiki URL, or to clear wiki login or check wiki login status. Works via MCP tools when available; when MCP is unavailable, runs scripts under this skill using the same session file (~/.cursor/wiki_sessions.json).
---

# Wiki Helper

Fetch internal wiki pages (e.g. Confluence), clear wiki session, or show session info. Session is shared with local_mcps: after the user runs `python -m local_mcps.cli wiki_login`, both MCP tools and this skill's scripts can use that session.

## When to Use

- User provides an internal wiki URL and asks to fetch/open/summarize the page.
- User asks to clear wiki login or log out of wiki.
- User asks whether they are logged in to the wiki or wants session status.

## Prerequisites

- User must log in once in terminal: `python -m local_mcps.cli wiki_login` (same as for MCP). Session is stored in `~/.cursor/wiki_sessions.json`.
- When using script fallback, Python and dependencies are needed: `pip install requests html2text beautifulsoup4`.

## Workflow

1. **Fetch wiki page**
   - Prefer: call MCP tool **fetch_internal_wiki** with the URL (and optional `download_images=True`).
   - If MCP is unavailable or the tool fails: run  
     `python ~/.cursor/skills/wiki-helper/scripts/fetch_wiki.py "<url>"`  
     (add `--no-images` to skip image download). Use the script stdout as the page content.
   - If the result says "No valid session" or "Session expired": tell the user to run  
     `python -m local_mcps.cli wiki_login`  
     in terminal, then retry.

2. **Clear wiki session**
   - Prefer: call MCP tool **wiki_clear_session** (with optional URL to clear one domain, or empty to clear all).
   - If MCP unavailable: run  
     `python ~/.cursor/skills/wiki-helper/scripts/clear_wiki_session.py`  
     (or pass a URL as first argument to clear that domain only). Use stdout as confirmation.

3. **Session info**
   - Prefer: call MCP tool **wiki_session_info** with the wiki URL.
   - If MCP unavailable: run  
     `python ~/.cursor/skills/wiki-helper/scripts/wiki_session_info.py "<url>"`  
     and use stdout as the session status.

## Examples

- "打开 http://wiki.enflame.cn/pages/viewpage.action?pageId=xxx" -> fetch that page (MCP or script), then summarize or use content.
- "清除当前 wiki 登录" -> clear session (MCP or clear_wiki_session.py).
- "我有没有登录 wiki？" -> session info (MCP or wiki_session_info.py).
