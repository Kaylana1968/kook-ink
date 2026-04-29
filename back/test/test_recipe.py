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


def test_upload_recipe_not_ok_when_missing_field_in_recipe():
    token = utils.generate_token(fake_user)
    headers = {"Authorization": f"Bearer {token}"}

    uncomplete_recipe = fake_recipe.copy()
    del uncomplete_recipe["name"]

    response = client.post("/recipe", json=uncomplete_recipe, headers=headers)

    assert response.status_code == 422


def test_upload_recipe_not_ok_when_ingredients_is_invalid():
    token = utils.generate_token(fake_user)
    headers = {"Authorization": f"Bearer {token}"}

    recipe_without_ingredients = fake_recipe.copy()

    # Check when ingredients is empty
    recipe_without_ingredients["ingredients"] = []

    response = client.post("/recipe", json=recipe_without_ingredients, headers=headers)

    assert response.status_code == 422

    # Check when ingredients has wrong format
    recipe_without_ingredients["ingredients"] = [{
        "key1": "Chocolate",
        "quantity": 3,
        "unit": "kg"
    }]

    response = client.post("/recipe", json=recipe_without_ingredients, headers=headers)

    assert response.status_code == 422

    # Check when ingredients has some with no name
    recipe_without_ingredients["ingredients"] = [{
        "name": " ",
        "quantity": 3,
        "unit": "kg"
    }]

    response = client.post("/recipe", json=recipe_without_ingredients, headers=headers)

    assert response.status_code == 422

    # Check when ingredients has some with unknown unit
    recipe_without_ingredients["ingredients"] = [{
        "name": "Chocolate",
        "quantity": 3,
        "unit": "iphone X"
    }]

    response = client.post("/recipe", json=recipe_without_ingredients, headers=headers)

    assert response.status_code == 422


def test_upload_recipe_not_ok_when_steps_is_invalid():
    token = utils.generate_token(fake_user)
    headers = {"Authorization": f"Bearer {token}"}

    recipe_with_invalid_steps = fake_recipe.copy()

    # Check when steps is empty
    recipe_with_invalid_steps["steps"] = []

    response = client.post("/recipe", json=recipe_with_invalid_steps, headers=headers)

    assert response.status_code == 422

    # Check when steps has empty entries
    recipe_with_invalid_steps["steps"] = ["step1", " "]

    response = client.post("/recipe", json=recipe_with_invalid_steps, headers=headers)

    assert response.status_code == 422
