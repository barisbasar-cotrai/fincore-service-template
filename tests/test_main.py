from fastapi.testclient import TestClient

from src.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_list_accounts():
    response = client.get("/api/v1/accounts")
    assert response.status_code == 200
    data = response.json()
    assert "accounts" in data
    assert data["count"] == 3


def test_get_account():
    response = client.get("/api/v1/accounts/ACC001")
    assert response.status_code == 200
    assert response.json()["name"] == "Alice Johnson"


def test_get_account_not_found():
    response = client.get("/api/v1/accounts/DOESNOTEXIST")
    assert response.status_code == 404
