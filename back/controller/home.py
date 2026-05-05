from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from common import database, models

router = APIRouter()

@router.get("/feed")
def get_feed(db: Session = Depends(database.get_db)):
    posts = db.query(models.Post).all()
    recipes = db.query(models.Recipe).all()

    result = []

    for post in posts:
        user = db.query(models.User).filter(models.User.id == post.user_id).first()

        result.append({
            "type": "post",
            "created_at": post.created_at.isoformat() if post.created_at else None,
            "item": {
                "id": post.id,
                "description": post.description,
                "image_link": post.image_link,
                "user_id": post.user_id,
                "username": user.username if user else "Utilisateur",
                "comments_count": db.query(models.PostComment).filter(
                    models.PostComment.post_id == post.id
                ).count(),
                "likes_count": db.query(models.PostLike).filter(
                    models.PostLike.post_id == post.id
                ).count(),
            }
        })

    for recipe in recipes:
        user = db.query(models.User).filter(models.User.id == recipe.user_id).first()

        result.append({
            "type": "recipe",
            "created_at": recipe.created_at.isoformat() if recipe.created_at else None,
            "item": {
                "id": recipe.id,
                "name": recipe.name,
                "user_id": recipe.user_id,
                "image_link": recipe.image_link,
                "preparation_time": recipe.preparation_time,
                "baking_time": recipe.baking_time,
                "person": recipe.person,
                "difficulty": recipe.difficulty,
                "username": user.username if user else "Utilisateur",
                "comments_count": db.query(models.RecipeComment).filter(
                    models.RecipeComment.recipe_id == recipe.id
                ).count(),
                "likes_count": db.query(models.RecipeLike).filter(
                    models.RecipeLike.recipe_id == recipe.id
                ).count(),
            }
        })

    result.sort(
        key=lambda x: x["created_at"] or "",
        reverse=True
    )

    return {"feed": result}
