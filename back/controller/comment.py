from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from common import database, models, utils
from pydantic import BaseModel


router = APIRouter()

class CommentCreate(BaseModel):
    content: str
    
@router.get("/post/{post_id}/comments")
def get_post_comments(
    post_id: int,
    db: Session = Depends(database.get_db)
):
    comments = (
        db.query(models.PostComment, models.User.username)
        .join(models.User, models.User.id == models.PostComment.user_id)
        .filter(models.PostComment.post_id == post_id)
        .order_by(models.PostComment.created_at.desc())
        .all()
    )

    return {
        "comments": [
            {
                "id": comment.id,
                "content": comment.content,
                "user_id": comment.user_id,
                "username": username,
                "created_at": comment.created_at.isoformat()
                if comment.created_at else "",
            }
            for comment, username in comments
        ]
    }


@router.post("/post/{post_id}/comments")
def create_post_comment(
    post_id: int,
    data: CommentCreate,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    comment = models.PostComment(
        content=data.content,
        post_id=post_id,
        user_id=int(user["id"]),
    )

    db.add(comment)
    db.commit()
    db.refresh(comment)

    return {"message": "Commentaire créé"}

@router.get("/recipe/{recipe_id}/comments")
def get_recipe_comments(
    recipe_id: int,
    db: Session = Depends(database.get_db)
):
    comments = (
        db.query(models.RecipeComment, models.User.username)
        .join(models.User, models.User.id == models.RecipeComment.user_id)
        .filter(models.RecipeComment.recipe_id == recipe_id)
        .order_by(models.RecipeComment.created_at.desc())
        .all()
    )

    return {
        "comments": [
            {
                "id": comment.id,
                "content": comment.content,
                "user_id": comment.user_id,
                "username": username,
                "created_at": comment.created_at.isoformat()
                if comment.created_at else "",
            }
            for comment, username in comments
        ]
    }


@router.post("/recipe/{recipe_id}/comments")
def create_recipe_comment(
    recipe_id: int,
    data: CommentCreate,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    comment = models.RecipeComment(
        content=data.content,
        recipe_id=recipe_id,
        user_id=int(user["id"]),
    )

    db.add(comment)
    db.commit()
    db.refresh(comment)

    return {"message": "Commentaire créé"}