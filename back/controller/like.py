from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()


# GET LIKE INFO (POST)
@router.get("/post/{post_id}/like")
def get_post_like(
    post_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    likes = db.query(models.PostLike).filter(
        models.PostLike.post_id == post_id
    ).count()

    liked = db.query(models.PostLike).filter(
        models.PostLike.user_id == user_id,
        models.PostLike.post_id == post_id
    ).first() is not None

    return {"liked": liked, "likes": likes}

# LIKE POST
@router.post("/post/{post_id}/like")
def like_post(
    post_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])
    post = db.query(models.Post).filter(models.Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post introuvable")

    if post.user_id == user_id:
        raise HTTPException(status_code=403, detail="Tu ne peux pas liker ton propre post")

    existing = db.query(models.PostLike).filter(
        models.PostLike.user_id == user_id,
        models.PostLike.post_id == post_id
    ).first()

    if existing:
        return {"message": "Déjà liké"}

    db.add(models.PostLike(user_id=user_id, post_id=post_id))
    db.commit()

    return {"message": "Post liké"}


# UNLIKE POST
@router.delete("/post/{post_id}/like")
def unlike_post(
    post_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    like = db.query(models.PostLike).filter(
        models.PostLike.user_id == user_id,
        models.PostLike.post_id == post_id
    ).first()

    if not like:
        raise HTTPException(status_code=404, detail="Like introuvable")

    db.delete(like)
    db.commit()

    return {"message": "Post unliké"}


# GET LIKE INFO (RECIPE)
@router.get("/recipe/{recipe_id}/like")
def get_recipe_like(
    recipe_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    likes = db.query(models.RecipeLike).filter(
        models.RecipeLike.recipe_id == recipe_id
    ).count()

    liked = db.query(models.RecipeLike).filter(
        models.RecipeLike.user_id == user_id,
        models.RecipeLike.recipe_id == recipe_id
    ).first() is not None

    return {"liked": liked, "likes": likes}

# LIKE RECIPE
@router.post("/recipe/{recipe_id}/like")
def like_recipe(
    recipe_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()
    if not recipe:
        raise HTTPException(status_code=404, detail="Recette introuvable")

    if recipe.user_id == user_id:
        raise HTTPException(status_code=403, detail="Tu ne peux pas liker ta propre recette")

    existing = db.query(models.RecipeLike).filter(
        models.RecipeLike.user_id == user_id,
        models.RecipeLike.recipe_id == recipe_id
    ).first()

    if existing:
        return {"message": "Déjà likée"}

    db.add(models.RecipeLike(user_id=user_id, recipe_id=recipe_id))
    db.commit()

    return {"message": "Recette likée"}


# UNLIKE RECIPE
@router.delete("/recipe/{recipe_id}/like")
def unlike_recipe(
    recipe_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    like = db.query(models.RecipeLike).filter(
        models.RecipeLike.user_id == user_id,
        models.RecipeLike.recipe_id == recipe_id
    ).first()

    if not like:
        raise HTTPException(status_code=404, detail="Like introuvable")

    db.delete(like)
    db.commit()

    return {"message": "Recette unlikée"}