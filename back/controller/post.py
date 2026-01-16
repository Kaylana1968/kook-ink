from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()

from pydantic import BaseModel
from typing import List, Optional

class PostCreate(BaseModel):
    description: str
    
# CREATE A POST
@router.post("/post")
def upload_recipe(post: PostCreate, user=Depends(utils.get_user), db: Session = Depends(database.get_db)):
    db_post = models.Recipe(
        description=post.description
    )

    db.add(db_post)
    db.commit()
    db.refresh(db_post)

    return {"message": "post créée", "id": db_post.id}