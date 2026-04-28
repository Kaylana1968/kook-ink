from test.test_main import client, fake_user
from common import utils

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


def test_upload_recipe_not_ok_when_no_headers_passed():
    response = client.post("/recipe", json=fake_recipe)

    assert response.status_code == 401
