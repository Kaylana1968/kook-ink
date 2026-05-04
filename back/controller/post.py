from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from common import database, models, utils
from pydantic import BaseModel
from typing import Optional

router = APIRouter(tags=["Post"])


class PostCreate(BaseModel):
    description: str
    image_link: Optional[str] = None


class PostUpdate(BaseModel):
    description: str
    image_link: Optional[str] = None


class CommentCreate(BaseModel):
    content: str


def serialize_post(post: models.Post, db: Session):
    user = db.query(models.User).filter(models.User.id == post.user_id).first()
    comments_count = (
        db.query(models.PostComment)
        .filter(models.PostComment.post_id == post.id)
        .count()
    )
    likes_count = (
        db.query(models.PostLike)
        .filter(models.PostLike.post_id == post.id)
        .count()
    )

    return {
        "id": post.id,
        "description": post.description,
        "image_link": post.image_link,
        "user_id": post.user_id,
        "username": user.username if user else "Utilisateur",
        "comments_count": comments_count,
        "likes_count": likes_count,
        "created_at": post.created_at.isoformat() if post.created_at else None,
    }


def serialize_comment(comment: models.PostComment, db: Session):
    user = db.query(models.User).filter(models.User.id == comment.user_id).first()

    return {
        "id": comment.id,
        "content": comment.content,
        "user_id": comment.user_id,
        "username": user.username if user else "Utilisateur",
        "created_at": comment.created_at.isoformat() if comment.created_at else None,
    }


# GET ALL POSTS
@router.get("/post")
def get_all_posts(db: Session = Depends(database.get_db)):
    posts = db.query(models.Post).order_by(
        models.Post.created_at.desc()
    ).all()

    result = []

    for post in posts:
        result.append(serialize_post(post, db))

    return {"posts": result}


# GET POSTS USER ME
@router.get("/post/me")
def get_my_posts(
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db)
):
    posts = db.query(models.Post).filter(
        models.Post.user_id == int(user["id"])
    ).order_by(models.Post.created_at.desc()).all()

    return {
        "posts": [
            {
                "id": post.id,
                "description": post.description,
                "image_link": post.image_link,
                "user_id": post.user_id,
                "comments_count": db.query(models.PostComment).filter(
                    models.PostComment.post_id == post.id
                ).count(),
                "likes_count": db.query(models.PostLike).filter(
                    models.PostLike.post_id == post.id
                ).count(),
                "created_at": post.created_at.isoformat() if post.created_at else None,
            }
            for post in posts
        ]
    }

# GET POSTS USER OTHER
@router.get("/post/user/{user_id}")
def get_user_posts(user_id: int, db: Session = Depends(database.get_db)):
    posts = db.query(models.Post).filter(
        models.Post.user_id == user_id
    ).order_by(models.Post.created_at.desc()).all()

    return {
        "posts": [
            {
                "id": p.id,
                "description": p.description,
                "image_link": p.image_link,
                "user_id": p.user_id,
                "comments_count": db.query(models.PostComment).filter(
                    models.PostComment.post_id == p.id
                ).count(),
                "likes_count": db.query(models.PostLike).filter(
                    models.PostLike.post_id == p.id
                ).count(),
            } for p in posts
        ]
    }
    

# CREATE A POST
@router.post("/post")
def upload_post(
    post: PostCreate,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    db_post = models.Post(
        description=post.description,
        image_link=post.image_link,
        user_id=int(user["id"]),
    )

    db.add(db_post)
    db.commit()
    db.refresh(db_post)

    return {"message": "post créée", "id": db_post.id}


# GET A POST BY ID
@router.get("/post/{post_id}")
def get_post(post_id: int, db: Session = Depends(database.get_db)):
    post = db.query(models.Post).filter(models.Post.id == post_id).first()

    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    return {"post": serialize_post(post, db)}


# GET POST COMMENTS
@router.get("/post/{post_id}/comments")
def get_post_comments(post_id: int, db: Session = Depends(database.get_db)):
    post = db.query(models.Post).filter(models.Post.id == post_id).first()

    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    comments = (
        db.query(models.PostComment)
        .filter(models.PostComment.post_id == post_id)
        .order_by(models.PostComment.created_at.asc())
        .all()
    )

    return {"comments": [serialize_comment(comment, db) for comment in comments]}


# CREATE POST COMMENT
@router.post("/post/{post_id}/comments", status_code=201)
def create_post_comment(
    post_id: int,
    comment: CommentCreate,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    post = db.query(models.Post).filter(models.Post.id == post_id).first()

    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    content = comment.content.strip()
    if not content:
        raise HTTPException(status_code=422, detail="Comment cannot be empty")

    db_comment = models.PostComment(
        content=content,
        post_id=post_id,
        user_id=int(user["id"]),
    )

    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)

    return {"comment": serialize_comment(db_comment, db)}


# DELETE A POST
@router.delete("/post/{post_id}")
def delete_post(
    post_id: int,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    post = db.query(models.Post).filter(models.Post.id == post_id).first()

    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    if post.user_id != int(user["id"]):
        raise HTTPException(status_code=403, detail="Not allowed to delete this post")

    try:
        db.delete(post)
        db.commit()
        return {"message": "Post supprimé"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# CHANGE A POST
@router.put("/post/{post_id}")
def update_post(
    post_id: int,
    post_update: PostUpdate,
    user=Depends(utils.get_user),
    db: Session = Depends(database.get_db),
):
    post = db.query(models.Post).filter(models.Post.id == post_id).first()

    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    if post.user_id != int(user["id"]):
        raise HTTPException(status_code=403, detail="Not allowed to edit this post")

    post.description = post_update.description
    post.image_link = post_update.image_link

    db.commit()
    db.refresh(post)

    return {
        "message": "Post modifié",
        "post": {
            "id": post.id,
            "description": post.description,
            "image_link": post.image_link,
            "user_id": post.user_id,
            "created_at": post.created_at.isoformat() if post.created_at else None,
        },
    }
