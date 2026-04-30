from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()


@router.get("/feed")
def get_feed(
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    current_user_id = int(user["id"])

    # IDs des utilisateurs que je suis
    following_rows = db.query(models.Follow.followed_user_id).filter(
        models.Follow.following_user_id == current_user_id
    ).all()

    following_ids = [row[0] for row in following_rows]

    posts = db.query(models.Post).all()
    recipes = db.query(models.Recipe).all()

    result = []

    for post in posts:
        user_obj = db.query(models.User).filter(
            models.User.id == post.user_id
        ).first()

        result.append({
            "type": "post",
            "created_at": post.created_at.isoformat() if post.created_at else "",
            "is_following": post.user_id in following_ids,
            "is_mine": post.user_id == current_user_id,
            "is_priority": post.user_id in following_ids or post.user_id == current_user_id,
            "item": {
                "id": post.id,
                "description": post.description,
                "user_id": post.user_id,
                "username": user_obj.username if user_obj else "Utilisateur",
            }
        })

    for recipe in recipes:
        user_obj = db.query(models.User).filter(
            models.User.id == recipe.user_id
        ).first()

        result.append({
            "type": "recipe",
            "created_at": recipe.created_at.isoformat() if recipe.created_at else "",
            "is_following": recipe.user_id in following_ids,
            "is_mine": recipe.user_id == current_user_id,
            "is_priority": recipe.user_id in following_ids or recipe.user_id == current_user_id,
            "item": {
                "id": recipe.id,
                "name": recipe.name,
                "user_id": recipe.user_id,
                "image_link": recipe.image_link,
                "preparation_time": recipe.preparation_time,
                "baking_time": recipe.baking_time,
                "person": recipe.person,
                "difficulty": recipe.difficulty,
                "username": user_obj.username if user_obj else "Utilisateur",
            }
        })

    result.sort(
        key=lambda x: (
            x["is_priority"],
            x["created_at"]
        ),
        reverse=True
    )

    return {"feed": result}