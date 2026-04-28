from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter(tags=["Recipe"])

from pydantic import BaseModel
from typing import List, Optional


class IngredientCreate(BaseModel):
    name: str
    quantity: float
    unit: models.UnitEnum

class RecipeCreate(BaseModel):
    name: str
    tips: Optional[str] = None
    difficulty: int
    preparation_time: int
    baking_time: int
    person: int
    image_link: Optional[str] = None
    video_link: Optional[str] = None
    steps: List[str]
    ingredients: List[IngredientCreate]

# GET ALL RECIPE ME
@router.get("/recipe/me")
def get_my_recipes(
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    recipes = db.query(models.Recipe).filter(
        models.Recipe.user_id == user_id
    ).all()

    result = []

    for recipe in recipes:
        result.append({
            "id": recipe.id,
            "name": recipe.name,
            "difficulty": recipe.difficulty,
            "preparation_time": recipe.preparation_time,
            "baking_time": recipe.baking_time,
            "person": recipe.person,
            "image_link": recipe.image_link,
        })

    return {"recipes": result}

# GET ALL RECIPES
@router.get("/recipe")
def get_recipes(db: Session = Depends(database.get_db)):
    recipes = db.query(models.Recipe).limit(10).all()

    to_return = []

    for recipe in recipes:
        steps = (
            db.query(models.Step)
            .filter(models.Step.recipe_id == recipe.id)
            .order_by(models.Step.number)
            .all()
        )

        ingredients = (
            db.query(models.RecipeIngredient)
            .filter(models.RecipeIngredient.recipe_id == recipe.id)
            .all()
        )

        to_return.append(
            {
                "id": recipe.id,
                "name": recipe.name,
                "tips": recipe.tips,
                "difficulty": recipe.difficulty,
                "preparation_time": recipe.preparation_time,
                "baking_time": recipe.baking_time,
                "person": recipe.person,
                "image_link": recipe.image_link,
                "video_link": recipe.video_link,
                "steps": [step.content for step in steps],
                "ingredients": [
                    {
                        "name": ingredient.ingredient,
                        "quantity": ingredient.quantity,
                        "unit": ingredient.unit,
                    }
                    for ingredient in ingredients
                ],
            }
        )

    return {"recipes": to_return}


# CREATE A RECIPE
@router.post("/recipe")
def upload_recipe(
    recipe: RecipeCreate,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    db_recipe = models.Recipe(
        name=recipe.name,
        tips=recipe.tips,
        difficulty=recipe.difficulty,
        preparation_time=recipe.preparation_time,
        baking_time=recipe.baking_time,
        person=recipe.person,
        image_link=recipe.image_link,
        video_link=recipe.video_link,
        user_id=int(user["id"]),
    )

    db.add(db_recipe)
    db.commit()
    db.refresh(db_recipe)

    for i in range(len(recipe.steps)):
        db.add(
            models.Step(content=recipe.steps[i], number=i + 1, recipe_id=db_recipe.id)
        )

    for ingredient in recipe.ingredients:
        db.add(
            models.RecipeIngredient(
                ingredient=ingredient.name,
                quantity=ingredient.quantity,
                unit=ingredient.unit.value,
                recipe_id=db_recipe.id,
            )
        )

    db.commit()

    return {"message": "Recette créée", "id": db_recipe.id}


# UPDATE A RECIPE
@router.patch("/recipe/{recipe_id}")
def update_recipe(
    recipe_id: int, recipe: RecipeCreate, db: Session = Depends(database.get_db)
):
    db_recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not db_recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    try:
        db_recipe.name = recipe.name
        db_recipe.tips = recipe.tips
        db_recipe.difficulty = recipe.difficulty
        db_recipe.preparation_time = recipe.preparation_time
        db_recipe.baking_time = recipe.baking_time
        db_recipe.person = recipe.person
        db_recipe.image_link = recipe.image_link
        db_recipe.video_link = recipe.video_link

        db.query(models.Step).filter(models.Step.recipe_id == recipe_id).delete(
            synchronize_session=False
        )

        db.query(models.RecipeIngredient).filter(
            models.RecipeIngredient.recipe_id == recipe_id
        ).delete(synchronize_session=False)

        for i, step in enumerate(recipe.steps):
            db.add(models.Step(content=step, number=i + 1, recipe_id=recipe_id))

        for ingredient in recipe.ingredients:
            db.add(
                models.RecipeIngredient(
                    ingredient=ingredient.name,
                    quantity=ingredient.quantity,
                    unit=ingredient.unit.value,
                    recipe_id=recipe_id,
                )
            )

        db.commit()
        db.refresh(db_recipe)

        return {"message": "Recette modifiée", "id": db_recipe.id}

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500, detail=f"Erreur modification recette : {str(e)}"
        )


# DELETE A RECIPE
@router.delete("/recipe/{recipe_id}", status_code=204)
def delete_recipe(recipe_id: int, db: Session = Depends(database.get_db)):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    try:
        db.query(models.RecipeIngredient).filter(
            models.RecipeIngredient.recipe_id == recipe_id
        ).delete(synchronize_session=False)

        db.query(models.Step).filter(models.Step.recipe_id == recipe_id).delete(
            synchronize_session=False
        )

        db.delete(recipe)
        db.commit()
        return

    except Exception as e:
        db.rollback()
        print(f"Erreur suppression recette : {e}")
        raise HTTPException(
            status_code=500, detail=f"Erreur suppression recette : {str(e)}"
        )
