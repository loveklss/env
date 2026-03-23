"""Manages persistent Jira session storage. Same pattern as wiki_helper."""

import json
import os
from datetime import datetime, timedelta
from typing import Optional, Dict
from urllib.parse import urlparse


class SessionManager:
    def __init__(self, session_file: Optional[str] = None):
        if session_file is None:
            cursor_dir = os.path.expanduser("~/.cursor")
            os.makedirs(cursor_dir, exist_ok=True)
            session_file = os.path.join(cursor_dir, "jira_sessions.json")
        self.session_file = session_file
        self._ensure_file_exists()

    def _ensure_file_exists(self):
        if not os.path.exists(self.session_file):
            with open(self.session_file, "w", encoding="utf-8") as f:
                json.dump({}, f)
        try:
            os.chmod(self.session_file, 0o600)
        except Exception:
            pass

    def _extract_domain(self, url: str) -> str:
        if not url.startswith(("http://", "https://")):
            url = "http://" + url
        return urlparse(url).netloc

    def _load_sessions(self) -> Dict:
        try:
            with open(self.session_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            return {}

    def _save_sessions(self, sessions: Dict):
        with open(self.session_file, "w", encoding="utf-8") as f:
            json.dump(sessions, f, indent=2, ensure_ascii=False)
        try:
            os.chmod(self.session_file, 0o600)
        except Exception:
            pass

    def save_session(self, url: str, cookies: Dict, headers: Optional[Dict] = None, expires_hours: int = 24):
        domain = self._extract_domain(url)
        sessions = self._load_sessions()
        sessions[domain] = {
            "cookies": cookies,
            "headers": headers or {},
            "created_at": datetime.now().isoformat(),
            "expires_hours": expires_hours,
        }
        self._save_sessions(sessions)

    def load_session(self, url: str) -> Optional[Dict]:
        domain = self._extract_domain(url)
        return self._load_sessions().get(domain)

    def has_valid_session(self, url: str) -> bool:
        session = self.load_session(url)
        if not session:
            return False
        try:
            created_at = datetime.fromisoformat(session["created_at"])
            expires_hours = session.get("expires_hours", 24)
            return datetime.now() < created_at + timedelta(hours=expires_hours)
        except (ValueError, KeyError):
            return False

    def clear_session(self, url: Optional[str] = None):
        if url is None:
            self._save_sessions({})
        else:
            domain = self._extract_domain(url)
            sessions = self._load_sessions()
            if domain in sessions:
                del sessions[domain]
                self._save_sessions(sessions)

    def get_session_info(self, url: str) -> Optional[str]:
        session = self.load_session(url)
        if not session:
            return None
        try:
            created_at = datetime.fromisoformat(session["created_at"])
            expires_hours = session.get("expires_hours", 24)
            expires_at = created_at + timedelta(hours=expires_hours)
            return (
                f"Session for {self._extract_domain(url)}:\n"
                f"  Created: {created_at.strftime('%Y-%m-%d %H:%M:%S')}\n"
                f"  Expires: {expires_at.strftime('%Y-%m-%d %H:%M:%S')}\n"
                f"  Status: {'Valid' if datetime.now() < expires_at else 'Expired'}"
            )
        except (ValueError, KeyError):
            return "Session data corrupted"
