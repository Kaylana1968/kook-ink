from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter(tags=["Like"])


def _get_like_model(content_type: str):
    if content_type == "post":
        return models.Post, models.PostLike, "post_id"

    if content_type == "recipe":
        return models.Recipe, models.RecipeLike, "recipe_id"

    raise HTTPException(status_code=400, detail="Invalid like type")


def _get_like_query(db: Session, like_model, like_field: str, user_id: int, item_id: int):
    return db.query(like_model).filter(
        like_model.user_id == user_id,
        getattr(like_model, like_field) == item_id,
    )


@router.get("/like/{content_type}/{item_id}")
def get_like_status(
    content_type: str,
    item_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    item_model, like_model, like_field = _get_like_model(content_type)

    item = db.query(item_model).filter(item_model.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    count = db.query(like_model).filter(getattr(like_model, like_field) == item_id).count()
    liked = (
        _get_like_query(db, like_model, like_field, int(user["id"]), item_id).first()
        is not None
    )

    return {"liked": liked, "count": count}


@router.post("/like/{content_type}/{item_id}", status_code=201)
def like_item(
    content_type: str,
    item_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    item_model, like_model, like_field = _get_like_model(content_type)
    user_id = int(user["id"])

    item = db.query(item_model).filter(item_model.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    existing_like = _get_like_query(
        db, like_model, like_field, user_id, item_id
    ).first()

    if existing_like:
        return {"message": "Already liked"}

    like = like_model(user_id=user_id, **{like_field: item_id})
    db.add(like)
    db.commit()

    return {"message": "Liked"}


@router.delete("/like/{content_type}/{item_id}", status_code=204)
def unlike_item(
    content_type: str,
    item_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    _, like_model, like_field = _get_like_model(content_type)

    like = _get_like_query(
        db, like_model, like_field, int(user["id"]), item_id
    ).first()

    if not like:
        return None

    db.delete(like)
    db.commit()

    return None
