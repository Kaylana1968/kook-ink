from test.test_main import client, get_db as override_get_db
from common import utils, models, database
from main import app

app.dependency_overrides[database.get_db] = override_get_db

fake_user = models.User(
    id=1, username="test", email="test@gmail.com", password=utils.hash_password("test")
)

fake_recipe = {
    "name": "Gateau au Chocolat",
    "tips": "Don't overbake!",
    "difficulty": 3,
    "preparation_time": 15,
    "baking_time": 25,
    "person": 6,
    "steps": ["Melt chocolate", "Mix eggs", "Bake"],
    "ingredients": [
        {"name": "Chocolate", "quantity": 200, "unit": "g"},
        {"name": "Eggs", "quantity": 4, "unit": "u"},
    ],
}


def test_upload_recipe_ok_when_everything_ok():
    token = utils.generate_token(fake_user)
    headers = {"Authorization": f"Bearer {token}"}

    response = client.post("/recipe", json=fake_recipe, headers=headers)

    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Recette créée"
    assert "id" in data


def test_upload_recipe_not_ok_when_no_headers_passed():
    response = client.post("/recipe", json=fake_recipe)

    assert response.status_code == 401
