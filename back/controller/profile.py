from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter(tags=["Follow"])


# GET FOLLOWERS / FOLLOWING COUNT
@router.get("/follow/count")
def get_follow_count(
    user=Depends(utils.get_user), db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    following_count = (
        db.query(models.Follow)
        .filter(models.Follow.following_user_id == user_id)
        .count()
    )

    followers_count = (
        db.query(models.Follow)
        .filter(models.Follow.followed_user_id == user_id)
        .count()
    )

    return {"followers": followers_count, "following": following_count}

# INFO USER
@router.get("/profile/me")
def get_my_profile(
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    user_id = int(user["id"])

    db_user = db.query(models.User).filter(models.User.id == user_id).first()

    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "id": db_user.id,
        "username": db_user.username,
        "description": db_user.description,
    }