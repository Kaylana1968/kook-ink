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

# GET FOLLOWERS / FOLLOWING COUNT USER OTHER
@router.get("/follow/count/{user_id}")
def get_user_follow_count(
    user_id: int,
    db: Session = Depends(database.get_db)
):
    followers = db.query(models.Follow).filter(
        models.Follow.followed_user_id == user_id
    ).count()

    following = db.query(models.Follow).filter(
        models.Follow.following_user_id == user_id
    ).count()

    return {
        "followers": followers,
        "following": following,
    }


@router.get("/follow/status/{user_id}")
def get_follow_status(
    user_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    current_user_id = int(user["id"])

    follow = db.query(models.Follow).filter(
        models.Follow.following_user_id == current_user_id,
        models.Follow.followed_user_id == user_id,
    ).first()

    return {"is_following": follow is not None}


@router.post("/follow/{user_id}", status_code=201)
def follow_user(
    user_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    current_user_id = int(user["id"])

    if current_user_id == user_id:
        raise HTTPException(status_code=400, detail="Cannot follow yourself")

    followed_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not followed_user:
        raise HTTPException(status_code=404, detail="User not found")

    existing_follow = db.query(models.Follow).filter(
        models.Follow.following_user_id == current_user_id,
        models.Follow.followed_user_id == user_id,
    ).first()

    if existing_follow:
        return {"message": "Already following"}

    follow = models.Follow(
        following_user_id=current_user_id,
        followed_user_id=user_id,
    )

    db.add(follow)
    db.commit()

    return {"message": "User followed"}


@router.delete("/follow/{user_id}", status_code=204)
def unfollow_user(
    user_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    current_user_id = int(user["id"])

    follow = db.query(models.Follow).filter(
        models.Follow.following_user_id == current_user_id,
        models.Follow.followed_user_id == user_id,
    ).first()

    if not follow:
        return None

    db.delete(follow)
    db.commit()

    return None

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
    
# INFO USER OTHER
@router.get("/profile/{user_id}")
def get_user_profile(user_id: int, db: Session = Depends(database.get_db)):
    
    user = db.query(models.User).filter(models.User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "id": user.id,
        "username": user.username,
        "description": user.description,
    }
