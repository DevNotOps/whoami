import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

from main import app  # noqa: E402


def test_health():
    r = app.test_client().get("/health")
    assert r.status_code == 200
    assert r.get_json() == {"status": "ok"}


def test_index_fields():
    r = app.test_client().get("/", headers={"X-Forwarded-For": "203.0.113.7"})
    data = r.get_json()
    assert r.status_code == 200
    assert data["service"] == "whoami"
    assert data["client_ip"] == "203.0.113.7"
    assert data["hostname"]
    assert data["uptime_seconds"] >= 0
