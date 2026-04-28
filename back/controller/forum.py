from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from common import database, models, utils

router = APIRouter(tags=["Forum"])

@router.get("/forum/posts")
def get_all_posts(db: Session = Depends(database.get_db)):

    posts = db.query(
        models.ForumPost,
        models.User.username,
        func.count(models.ForumPostResponse.id).label("replies_count")
    ).join(models.User, models.ForumPost.user_id == models.User.id) \
     .outerjoin(models.ForumPostResponse, models.ForumPost.id == models.ForumPostResponse.forum_post_id) \
     .group_by(models.ForumPost.id, models.User.username) \
     .all()

    return [
        {
            "id": post.ForumPost.id,
            "title": post.ForumPost.title,
            "description": post.ForumPost.description,
            "author": post.username,
            "replies_count": post.replies_count,
            "created_at": post.ForumPost.created_at
        }
        for post in posts
    ]

@router.get("/forum/posts/{post_id}")
def get_post_detail(post_id: int, db: Session = Depends(database.get_db)):
    post = db.query(models.ForumPost).filter(models.ForumPost.id == post_id).first()
    responses = db.query(models.ForumPostResponse, models.User.username)\
                  .join(models.User)\
                  .filter(models.ForumPostResponse.forum_post_id == post_id).all()
    
    return {
        "title": post.title,
        "description": post.description,
        "responses": [{"author": r.username, "content": r.ForumPostResponse.content} for r in responses]
    }