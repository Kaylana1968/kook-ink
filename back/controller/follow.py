from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()

from pydantic import BaseModel

class Following(BaseModel):
    description: str
    
    
# GET ALL FOLLOWING
@router.get("/following")
def get_posts(db: Session = Depends(database.get_db)):
    posts = db.query(models.Post).limit(10).all()

    to_return = []
    for post in posts: 
        user = db.get(models.User, post.user_id)
        to_return.append({
            "description": post.description,
            "user": user
        })

    return {"posts": to_return}
