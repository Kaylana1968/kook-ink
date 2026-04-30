from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from common import database, models
from common.utils import get_user
from pydantic import BaseModel

router = APIRouter(tags=["Forum"])

class CreatePostSchema(BaseModel):
    title: str
    description: str
    username: str

class CreateResponseSchema(BaseModel):
    content: str


@router.get("/forum/posts")
def get_all_posts(db: Session = Depends(database.get_db)):
    posts = (
        db.query(
            models.ForumPost,
            models.User.username,
            func.count(models.ForumPostResponse.id).label("responses_count"),
        )
        .join(models.User, models.ForumPost.user_id == models.User.id)
        .outerjoin(
            models.ForumPostResponse,
            models.ForumPost.id == models.ForumPostResponse.forum_post_id,
        )
        .group_by(models.ForumPost.id, models.User.username)
        .order_by(models.ForumPost.created_at.desc())
        .all()
    )

    return [
        {
            "id": post.ForumPost.id,
            "title": post.ForumPost.title,
            "description": post.ForumPost.description,
            "username": post.username,
            "responses_count": post.responses_count,
            "created_at": post.ForumPost.created_at,
        }
        for post in posts
    ]


@router.post("/forum/posts", status_code=201)
def create_post(
    body: CreatePostSchema,
    db: Session = Depends(database.get_db),
    current_user: dict = Depends(get_user),
):
    new_post = models.ForumPost(
        title=body.title,
        description=body.description,
        user_id=int(current_user["id"]),
    )
    db.add(new_post)
    db.commit()
    db.refresh(new_post)
    return {"id": new_post.id, "title": new_post.title}


@router.get("/forum/posts/{post_id}")
def get_post_detail(post_id: int, db: Session = Depends(database.get_db)):
    post = (
        db.query(models.ForumPost, models.User.username.label("username"))
        .join(models.User, models.ForumPost.user_id == models.User.id)
        .filter(models.ForumPost.id == post_id)
        .first()
    )

    if not post:
        raise HTTPException(status_code=404, detail="Post introuvable")

    rows = (
        db.query(
            models.ForumPostResponse,
            models.User.username.label("username"),
            func.count(models.ForumPostResponseUpvote.user_id).label("upvotes"),
        )
        .join(models.User, models.ForumPostResponse.user_id == models.User.id)
        .outerjoin(
            models.ForumPostResponseUpvote,
            models.ForumPostResponse.id
            == models.ForumPostResponseUpvote.forum_post_response_id,
        )
        .filter(models.ForumPostResponse.forum_post_id == post_id)
        .group_by(models.ForumPostResponse.id, models.User.username)
        .order_by(models.ForumPostResponse.created_at.asc())
        .all()
    )

    return {
        "title": post.ForumPost.title,
        "description": post.ForumPost.description,
        "username": post.username,
        "responses": [
            {
                "id": r.ForumPostResponse.id,
                "username": r.username or "Utilisateur",
                "content": r.ForumPostResponse.content,
                "upvotes": r.upvotes,
            }
            for r in rows
        ],
    }


@router.post("/forum/posts/{post_id}/responses", status_code=201)
def create_response(
    post_id: int,
    body: CreateResponseSchema,
    db: Session = Depends(database.get_db),
    current_user: dict = Depends(get_user),
):
    post = db.query(models.ForumPost).filter(models.ForumPost.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post introuvable")

    new_resp = models.ForumPostResponse(
        content=body.content,
        forum_post_id=post_id,
        user_id=int(current_user["id"]),
    )
    db.add(new_resp)
    db.commit()
    db.refresh(new_resp)
    return {"id": new_resp.id, "content": new_resp.content}


@router.post("/forum/responses/{response_id}/upvote")
def toggle_upvote(
    response_id: int,
    db: Session = Depends(database.get_db),
    current_user: dict = Depends(get_user),
):
    user_id = int(current_user["id"])

    response = db.query(models.ForumPostResponse).filter(models.ForumPostResponse.id == response_id).first()
    if not response:
        raise HTTPException(status_code=404, detail="Réponse introuvable")

    existing = (
        db.query(models.ForumPostResponseUpvote)
        .filter(
            models.ForumPostResponseUpvote.forum_post_response_id == response_id,
            models.ForumPostResponseUpvote.user_id == user_id,
        )
        .first()
    )

    if existing:
        db.delete(existing)
        db.commit()
        return {"upvoted": False}

    db.add(models.ForumPostResponseUpvote(
        forum_post_response_id=response_id,
        user_id=user_id,
    ))
    db.commit()
    return {"upvoted": True}