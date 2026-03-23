---
name: jira-helper
description: Fetches internal Jira (http://jira.enflame.cn) issue content, clears Jira session, or shows session info. Use when the user asks to open/fetch/summarize a Jira issue URL or issue key, or to clear Jira login or check Jira login status. Standalone skill with built-in authentication and session management.
---

# Jira Helper

Fetch internal Jira issue pages (e.g. http://jira.enflame.cn), clear Jira session, or show session info. Same usage pattern as wiki_helper; uses a separate session file and Jira REST/login flow.

## When to Use

- User provides a Jira URL (e.g. http://jira.enflame.cn/browse/CAPS-12345) or issue key (e.g. CAPS-12345) and asks to fetch/open/summarize the issue.
- User asks to clear Jira login or check Jira login status.

## Prerequisites

- User must log in once in terminal. Session is stored in `~/.cursor/jira_sessions.json` (Unix) or `%USERPROFILE%\.cursor\jira_sessions.json` (Windows).
- Python dependencies: `requests`; for HTML fallback also `html2text`, `beautifulsoup4` (Cursor AI will handle installation if needed).

## Path Handling

**IMPORTANT**: Use platform-appropriate paths when running scripts:

- **Windows**: Use `$env:USERPROFILE\.cursor\skills\jira_helper\`
- **Unix/Mac**: Use `~/.cursor/skills/jira_helper/`

## Workflow

1. **Fetch Jira issue**
   - **Unix/Mac**: `python ~/.cursor/skills/jira_helper/scripts/fetch_jira.py "<url_or_issue_key>"`
   - **Windows**: `python %USERPROFILE%\.cursor\skills\jira_helper\scripts\fetch_jira.py "<url_or_issue_key>"`
   - Examples: `fetch_jira.py "http://jira.enflame.cn/browse/CAPS-12345"` or `fetch_jira.py "CAPS-12345"`
   - Use the script stdout as the issue content (Markdown).
   - If the result contains "No valid session" or "Session expired": tell the user:
     ```
     会话已过期，请在终端运行以下命令重新登录：

     Windows:
     python %USERPROFILE%\.cursor\skills\jira_helper\jira_helper_cli.py login

     Unix/Mac:
     python ~/.cursor/skills/jira_helper/jira_helper_cli.py login

     登录后再重试。
     ```
     Then retry after user logs in.

2. **Clear Jira session**
   - **Unix/Mac**: `python ~/.cursor/skills/jira_helper/scripts/clear_jira_session.py [URL]`
   - Or CLI: `python <path>/jira_helper_cli.py logout [URL|--all]`
   - Use stdout as confirmation.

3. **Session info**
   - **Unix/Mac**: `python ~/.cursor/skills/jira_helper/scripts/jira_session_info.py "<url>"`
   - Or CLI: `python <path>/jira_helper_cli.py info "<url>"`
   - Use stdout as the session status.

## Examples

- "打开 http://jira.enflame.cn/browse/CAPS-12345" -> fetch that issue using fetch_jira.py, then summarize or use content.
- "总结这个 Jira：CAPS-12345" -> fetch_jira.py CAPS-12345, then summarize.
- "清除当前 Jira 登录" -> clear session using clear_jira_session.py.
- "我有没有登录 Jira？" -> session info using jira_session_info.py.
