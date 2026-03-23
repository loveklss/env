"""Jira authentication: try REST API first, fall back to form-based login (e.g. login.jsp)."""

import requests
from typing import Tuple, Dict, Optional
from urllib.parse import urljoin, urlparse

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None


class Authenticator:
    def __init__(self, timeout: int = 30):
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        })

    def _base(self, url: str) -> str:
        url = url.rstrip("/")
        if not url.startswith(("http://", "https://")):
            url = "http://" + url
        return url

    def _rest_session_url(self, base_url: str) -> str:
        return urljoin(self._base(base_url) + "/", "rest/auth/1/session")

    def _login_rest(self, url: str, username: str, password: str) -> Optional[Tuple[Dict, Dict]]:
        """Try REST API login. Returns (cookies, headers) or None on failure."""
        session_url = self._rest_session_url(url)
        payload = {"username": username, "password": password}
        try:
            r = self.session.post(
                session_url,
                json=payload,
                timeout=self.timeout,
                allow_redirects=True,
                headers={"Content-Type": "application/json"},
            )
        except Exception:
            return None
        if r.status_code != 200:
            return None
        cookies = dict(self.session.cookies)
        if not cookies:
            return None
        return cookies, dict(self.session.headers)

    def _find_jira_login_page(self, base_url: str) -> Optional[str]:
        base_url = self._base(base_url)
        for path in ["/login.jsp", "/secure/login", "/login", "/rest/auth/1/session"]:
            try:
                url = urljoin(base_url + "/", path.lstrip("/"))
                r = self.session.get(url, timeout=self.timeout, allow_redirects=True)
                if r.status_code == 200 and ("login" in r.text.lower() or "password" in r.text.lower() or "username" in r.text.lower()):
                    return r.url
            except Exception:
                continue
        return None

    def _parse_login_form(self, html: str, base_url: str) -> Optional[Dict]:
        if not BeautifulSoup:
            return None
        soup = BeautifulSoup(html, "html.parser")
        form = None
        for f in soup.find_all("form"):
            if "password" in str(f).lower() or "login" in str(f).lower():
                form = f
                break
        if not form:
            return None
        action = form.get("action", "")
        action = urljoin(base_url, action) if action else base_url
        username_field = None
        for name in ["os_username", "username", "j_username", "user", "login", "email"]:
            if form.find("input", {"name": name}):
                username_field = name
                break
        password_field = None
        for name in ["os_password", "password", "j_password", "pass", "pwd"]:
            if form.find("input", {"name": name, "type": "password"}):
                password_field = name
                break
        if not username_field or not password_field:
            return None
        hidden = {}
        for inp in form.find_all("input", {"type": "hidden"}):
            n = inp.get("name")
            if n:
                hidden[n] = inp.get("value", "")
        return {
            "action": action,
            "username_field": username_field,
            "password_field": password_field,
            "hidden_fields": hidden,
        }

    def _login_form(self, url: str, username: str, password: str) -> Tuple[Dict, Dict]:
        """Form-based login (Jira login.jsp / secure login)."""
        base_url = self._base(url)
        login_url = self._find_jira_login_page(url)
        if not login_url:
            raise Exception("Could not find Jira login page. Check URL.")
        r = self.session.get(login_url, timeout=self.timeout)
        r.raise_for_status()
        form_data = self._parse_login_form(r.text, base_url)
        if not form_data:
            raise Exception("Could not parse Jira login form. The site may use SSO or a different auth method.")
        payload = {**form_data["hidden_fields"]}
        payload[form_data["username_field"]] = username
        payload[form_data["password_field"]] = password
        login_resp = self.session.post(
            form_data["action"],
            data=payload,
            timeout=self.timeout,
            allow_redirects=True,
        )
        if login_resp.status_code >= 400:
            raise Exception(f"Login request failed (HTTP {login_resp.status_code}).")
        if "login" in login_resp.url.lower() and "login" in login_resp.text.lower():
            err = "Login failed. Invalid username or password."
            if "captcha" in login_resp.text.lower() or "recaptcha" in login_resp.text.lower():
                err += " (Captcha may be required on the server.)"
            raise Exception(err)
        cookies = dict(self.session.cookies)
        if not cookies:
            raise Exception("Login appeared to succeed but no session cookies were received.")
        return cookies, dict(self.session.headers)

    def login(self, url: str, username: str, password: str) -> Tuple[Dict, Dict]:
        """Login: try REST API first; on 403/404 or failure, use form-based login."""
        result = self._login_rest(url, username, password)
        if result is not None:
            return result
        return self._login_form(url, username, password)

    def test_session(self, url: str, cookies: Dict, headers: Dict = None) -> bool:
        base = self._base(url)
        test_url = urljoin(base + "/", "rest/auth/1/session")
        try:
            r = requests.get(
                test_url,
                cookies=cookies,
                headers=headers or {},
                timeout=self.timeout,
            )
            if r.status_code == 401:
                return False
            return r.status_code == 200
        except Exception:
            return False
