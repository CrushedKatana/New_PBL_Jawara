import os
import pytest
import requests

BASE_URL = os.environ.get("PMPL_API_BASE", "https://staging.example.com/api/v1")
VALID_USER = {"email": "qa+valid@example.com", "password": "Password123!"}
INVALID_USER = {"email": "qa+invalid@example.com", "password": "wrong"}

def test_login_success():
    resp = requests.post(f"{BASE_URL}/login", json=VALID_USER, timeout=10)
    assert resp.status_code == 200
    data = resp.json()
    assert "token" in data and data["token"], "Token should be returned"


def test_login_wrong_password():
    resp = requests.post(f"{BASE_URL}/login", json=INVALID_USER, timeout=10)
    assert resp.status_code == 401


def test_refresh_token_expired():
    expired_token = "expired.jwt.token"
    resp = requests.post(
        f"{BASE_URL}/auth/refresh",
        headers={"Authorization": f"Bearer {expired_token}"},
        timeout=10,
    )
    assert resp.status_code in (200, 401)
    # Flag a failure if server does not return 200 for valid but expired token
    if resp.status_code != 200:
        pytest.fail("Refresh token flow still failing (expected 200)")
