from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()

from pydantic import BaseModel

class PostCreate(BaseModel):
    description: str
    
    
# GET ALL POST
@router.get("/post")
def get_posts(db: Session = Depends(database.get_db)):
    posts = db.query(models.Post).limit(10).all()

    to_return = []
    for post in posts: 
        user = db.get(models.User, post.user_id)
        to_return.append({
            "id": post.id,
            "description": post.description,
            "user": user
        })

    return {"posts": to_return}

# CREATE A POST
@router.post("/post")
def upload_recipe(post: PostCreate, user=Depends(utils.get_user), db: Session = Depends(database.get_db)):
    db_post = models.Post(
        description=post.description,
        user_id=int(user["id"]),
    )

    db.add(db_post)
    db.commit()
    db.refresh(db_post)

    return {"message": "post créée", "id": db_post.id}

# DELETE A POST
@router.delete("/post/{post_id}")
def delete_recipe(post_id: int, db: Session = Depends(database.get_db)):
    post = db.query(models.Post).filter(models.Post.id == post_id).first()

    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    db.delete(post)

    try:
        db.commit()
        print(f"Post deleted successfully with ID: {post.id}")
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")
    finally:
        db.close()