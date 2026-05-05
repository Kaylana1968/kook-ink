from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from pydantic import BaseModel, field_validator
from typing import List, Optional
from common import database, models, utils

router = APIRouter(tags=["Recipe"])


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

    @field_validator("steps", "ingredients")
    @classmethod
    def lists_must_not_be_empty(cls, v: list):
        if len(v) == 0:
            raise ValueError("This list must contain at least one item")

        return v

    @field_validator("steps")
    @classmethod
    def check_steps_content(cls, v: List[str]):
        if any(not step.strip() for step in v):
            raise ValueError("All steps must contain text")

        return v

    @field_validator("ingredients")
    @classmethod
    def check_ingredients_content(cls, v: List[IngredientCreate]):
        if any(not ingredient.name.strip() for ingredient in v):
            raise ValueError("All ingredients must contain have a name")

        return v


class CommentCreate(BaseModel):
    content: str


def serialize_recipe_comment(comment: models.RecipeComment, db: Session):
    user = db.query(models.User).filter(models.User.id == comment.user_id).first()

    return {
        "id": comment.id,
        "content": comment.content,
        "user_id": comment.user_id,
        "username": user.username if user else "Utilisateur",
        "created_at": comment.created_at.isoformat() if comment.created_at else None,
    }


def get_recipe_comments_count(recipe_id: int, db: Session):
    return (
        db.query(models.RecipeComment)
        .filter(models.RecipeComment.recipe_id == recipe_id)
        .count()
    )


def get_recipe_likes_count(recipe_id: int, db: Session):
    return (
        db.query(models.RecipeLike)
        .filter(models.RecipeLike.recipe_id == recipe_id)
        .count()
    )


# GET ALL RECIPE ME
@router.get("/recipe/me")
def get_my_recipes(
    user=Depends(utils.get_user), db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    recipes = (
        db.query(models.Recipe)
        .filter(models.Recipe.user_id == user_id)
        .order_by(models.Recipe.created_at.desc())
        .all()
    )

    result = []

    for recipe in recipes:
        result.append(
            {
                "id": recipe.id,
                "name": recipe.name,
                "difficulty": recipe.difficulty,
                "preparation_time": recipe.preparation_time,
                "baking_time": recipe.baking_time,
                "person": recipe.person,
                "image_link": recipe.image_link,
                "comments_count": get_recipe_comments_count(recipe.id, db),
                "likes_count": get_recipe_likes_count(recipe.id, db),
            }
        )

    return {"recipes": result}


# GET RECIPES USER OTHER
@router.get("/recipe/user/{user_id}")
def get_user_recipes(user_id: int, db: Session = Depends(database.get_db)):
    recipes = (
        db.query(models.Recipe)
        .filter(models.Recipe.user_id == user_id)
        .order_by(models.Recipe.created_at.desc())
        .all()
    )

    return {
        "recipes": [
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
                "user_id": recipe.user_id,
                "comments_count": get_recipe_comments_count(recipe.id, db),
                "likes_count": get_recipe_likes_count(recipe.id, db),
            }
            for recipe in recipes
        ]
    }


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
                "comments_count": get_recipe_comments_count(recipe.id, db),
                "likes_count": get_recipe_likes_count(recipe.id, db),
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


# GET A RECIPE BY ID
@router.get("/recipe/{recipe_id}")
def get_recipes(recipe_id: int, db: Session = Depends(database.get_db)):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

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

    recipe_user = db.query(models.User).filter(models.User.id == recipe.user_id).first()

    to_return = {
        "id": recipe.id,
        "name": recipe.name,
        "tips": recipe.tips,
        "difficulty": recipe.difficulty,
        "preparation_time": recipe.preparation_time,
        "baking_time": recipe.baking_time,
        "person": recipe.person,
        "image_link": recipe.image_link,
        "video_link": recipe.video_link,
        "user_id": recipe.user_id,
        "username": recipe_user.username if recipe_user else "Utilisateur",
        "comments_count": get_recipe_comments_count(recipe.id, db),
        "likes_count": get_recipe_likes_count(recipe.id, db),
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

    return {"recipe": to_return}


# GET RECIPE COMMENTS
@router.get("/recipe/{recipe_id}/comments")
def get_recipe_comments(recipe_id: int, db: Session = Depends(database.get_db)):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    comments = (
        db.query(models.RecipeComment)
        .filter(models.RecipeComment.recipe_id == recipe_id)
        .order_by(models.RecipeComment.created_at.asc())
        .all()
    )

    return {
        "comments": [
            serialize_recipe_comment(comment, db)
            for comment in comments
        ]
    }


# CREATE RECIPE COMMENT
@router.post("/recipe/{recipe_id}/comments", status_code=201)
def create_recipe_comment(
    recipe_id: int,
    comment: CommentCreate,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    content = comment.content.strip()
    if not content:
        raise HTTPException(status_code=422, detail="Comment cannot be empty")

    db_comment = models.RecipeComment(
        content=content,
        recipe_id=recipe_id,
        user_id=int(user["id"]),
    )

    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)

    return {"comment": serialize_recipe_comment(db_comment, db)}


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
@router.put("/recipe/{recipe_id}")
def update_recipe(
    recipe_id: int,
    recipe: RecipeCreate,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    db_recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not db_recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    if db_recipe.user_id != int(user["id"]):
        raise HTTPException(status_code=403, detail="Not allowed to edit this recipe")

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
def delete_recipe(
    recipe_id: int, user=Depends(utils.get_user), db: Session = Depends(database.get_db)
):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    if recipe.user_id != int(user["id"]):
        raise HTTPException(status_code=403, detail="Not allowed to edit this recipe")

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
