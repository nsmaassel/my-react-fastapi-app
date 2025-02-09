import pytest
from fastapi.testclient import TestClient
from app.main import app, parse_cors_origins

client = TestClient(app)

def test_read_root():
    response = client.get("/api/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to the FastAPI backend!"}

def test_read_item():
    response = client.get("/api/items/1")
    assert response.status_code == 200
    assert response.json() == {"item_id": 1, "message": "This is your item."}

def test_health_check():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

@pytest.mark.parametrize("origins_input,expected", [
    (None, ["http://localhost:3000", "http://frontend:3000", "http://localhost", "http://frontend"]),
    ('["http://custom.com"]', ["http://custom.com"]),
    ('invalid', ["http://localhost:3000", "http://frontend:3000", "http://localhost", "http://frontend"]),
])
def test_parse_cors_origins(origins_input, expected):
    assert parse_cors_origins(origins_input) == expected