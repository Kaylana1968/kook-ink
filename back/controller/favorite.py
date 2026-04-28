from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()

# FAVORIS PROFIL
@router.get("/favorite")
def get_favorites(
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    post_likes = db.query(models.PostLike).filter(
        models.PostLike.user_id == user_id
    ).all()

    recipe_likes = db.query(models.RecipeLike).filter(
        models.RecipeLike.user_id == user_id
    ).all()

    result = []

    for like in post_likes:
        post = db.query(models.Post).filter(models.Post.id == like.post_id).first()

        if post:
            result.append({
                "type": "post",
                "created_at": post.created_at.isoformat() if post.created_at else None,
                "item": {
                    "id": post.id,
                    "description": post.description,
                    "user_id": post.user_id,
                }
            })

    for like in recipe_likes:
        recipe = db.query(models.Recipe).filter(models.Recipe.id == like.recipe_id).first()

        if recipe:
            result.append({
                "type": "recipe",
                "created_at": recipe.created_at.isoformat() if recipe.created_at else None,
                "item": {
                    "id": recipe.id,
                    "name": recipe.name,
                    "difficulty": recipe.difficulty,
                    "preparation_time": recipe.preparation_time,
                    "baking_time": recipe.baking_time,
                    "person": recipe.person,
                    "image_link": recipe.image_link,
                }
            })

    result.sort(
        key=lambda x: x["created_at"] or "",
        reverse=True
    )

    return {"favorites": result}