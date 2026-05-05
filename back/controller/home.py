from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()

@router.get("/feed")
def get_feed(
    date_order: str = Query("desc", pattern="^(asc|desc)$"),
    user=Depends(utils.get_optional_user),
    db: Session = Depends(database.get_db),
):
    posts = db.query(models.Post).all()
    recipes = db.query(models.Recipe).all()
    followed_user_ids = set()
    current_user_id = None

    if user is not None:
        current_user_id = int(user["id"])
        followed_user_ids = {
            follow.followed_user_id
            for follow in db.query(models.Follow)
            .filter(models.Follow.following_user_id == current_user_id)
            .all()
        }

    result = []

    for post in posts:
        user = db.query(models.User).filter(models.User.id == post.user_id).first()

        result.append({
            "type": "post",
            "created_at": post.created_at.isoformat() if post.created_at else None,
            "is_followed_author": post.user_id in followed_user_ids,
            "is_priority_author": post.user_id == current_user_id
            or post.user_id in followed_user_ids,
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
            "is_followed_author": recipe.user_id in followed_user_ids,
            "is_priority_author": recipe.user_id == current_user_id
            or recipe.user_id in followed_user_ids,
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

    reverse_date = date_order == "desc"

    def sort_key(feed_item):
        created_at = feed_item["created_at"] or datetime.min.isoformat()
        return (feed_item["is_priority_author"], created_at)

    result.sort(key=sort_key, reverse=reverse_date)
    result.sort(key=lambda item: item["is_priority_author"], reverse=True)

    return {"feed": result}
