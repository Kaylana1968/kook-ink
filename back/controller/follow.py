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

    # combien JE suis
    following_count = (
        db.query(models.Follow)
        .filter(models.Follow.following_user_id == user_id)
        .count()
    )

    # combien ME suivent
    followers_count = (
        db.query(models.Follow)
        .filter(models.Follow.followed_user_id == user_id)
        .count()
    )

    return {"followers": followers_count, "following": following_count}
