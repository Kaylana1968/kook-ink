from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from common import database, models

router = APIRouter()

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
    user_id: int
    steps: List[str]
    ingredients: List[IngredientCreate]


# GET ALL RECIPES
@router.get("/recipe")
def get_recipes(db: Session = Depends(database.get_db)):
    recipes = db.query(models.Recipe).limit(10).all()

    return {"recipes": recipes}


# CREATE A RECIPE
@router.post("/recipe")
def upload_recipe(recipe: RecipeCreate, db: Session = Depends(database.get_db)):
    db_recipe = models.Recipe(
        name=recipe.name,
        tips=recipe.tips,
        difficulty=recipe.difficulty,
        preparation_time=recipe.preparation_time,
        baking_time=recipe.baking_time,
        person=recipe.person,
        image_link=recipe.image_link,
        video_link=recipe.video_link,
        user_id=recipe.user_id,
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
def update_recipe(recipe_id: int, db: Session = Depends(database.get_db)):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    recipe.tips = "coucou"
    try:
        db.commit()
        db.refresh(recipe)
        return recipe
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")
    finally:
        db.close()


# DELETE A RECIPE
@router.delete("/recipe/{recipe_id}")
def delete_recipe(recipe_id: int, db: Session = Depends(database.get_db)):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    db.delete(recipe)

    try:
        db.commit()
        print(f"Recipe deleted successfully with ID: {recipe.id}")
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")
    finally:
        db.close()
