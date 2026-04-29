from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()


# MY FAVOURITES PROFIL
@router.get("/favorite")
def get_favorites(
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    post_likes = db.query(models.PostLike).filter(
        models.PostLike.user_id == user_id
    ).order_by(models.PostLike.created_at.desc()).all()

    recipe_likes = db.query(models.RecipeLike).filter(
        models.RecipeLike.user_id == user_id
    ).order_by(models.RecipeLike.created_at.desc()).all()

    result = []

    for like in post_likes:
        post = db.query(models.Post).filter(
            models.Post.id == like.post_id
        ).first()

        if post:
            user = db.query(models.User).filter(
                models.User.id == post.user_id
            ).first()

            result.append({
                "type": "post",
                "created_at": like.created_at.isoformat() if like.created_at else None,
                "item": {
                    "id": post.id,
                    "description": post.description,
                    "user_id": post.user_id,
                    "username": user.username if user else "Utilisateur",
                }
            })

    for like in recipe_likes:
        recipe = db.query(models.Recipe).filter(
            models.Recipe.id == like.recipe_id
        ).first()

        if recipe:
            user = db.query(models.User).filter(
                models.User.id == recipe.user_id
            ).first()

            result.append({
                "type": "recipe",
                "created_at": like.created_at.isoformat() if like.created_at else None,
                "item": {
                    "id": recipe.id,
                    "name": recipe.name,
                    "username": user.username if user else "Utilisateur",
                    "difficulty": recipe.difficulty,
                    "preparation_time": recipe.preparation_time,
                    "baking_time": recipe.baking_time,
                    "person": recipe.person,
                    "image_link": recipe.image_link,
                }
            })

    return {"favorites": result}


# FAVOURITES PROFIL
@router.get("/favorite/user/{user_id}")
def get_user_favorites(
    user_id: int,
    db: Session = Depends(database.get_db)
):
    post_likes = db.query(models.PostLike).filter(
        models.PostLike.user_id == user_id
    ).order_by(models.PostLike.created_at.desc()).all()

    recipe_likes = db.query(models.RecipeLike).filter(
        models.RecipeLike.user_id == user_id
    ).order_by(models.RecipeLike.created_at.desc()).all()

    result = []

    for like in post_likes:
        post = db.query(models.Post).filter(
            models.Post.id == like.post_id
        ).first()

        if post:
            user = db.query(models.User).filter(
                models.User.id == post.user_id
            ).first()

            result.append({
                "type": "post",
                "created_at": like.created_at.isoformat() if like.created_at else None,
                "item": {
                    "id": post.id,
                    "description": post.description,
                    "user_id": post.user_id,
                    "username": user.username if user else "Utilisateur",
                }
            })

    for like in recipe_likes:
        recipe = db.query(models.Recipe).filter(
            models.Recipe.id == like.recipe_id
        ).first()

        if recipe:
            user = db.query(models.User).filter(
                models.User.id == recipe.user_id
            ).first()

            result.append({
                "type": "recipe",
                "created_at": like.created_at.isoformat() if like.created_at else None,
                "item": {
                    "id": recipe.id,
                    "name": recipe.name,
                    "user_id": recipe.user_id,
                    "username": user.username if user else "Utilisateur",
                    "difficulty": recipe.difficulty,
                    "preparation_time": recipe.preparation_time,
                    "baking_time": recipe.baking_time,
                    "person": recipe.person,
                    "image_link": recipe.image_link,
                }
            })

    return {"favorites": result}