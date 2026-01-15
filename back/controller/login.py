from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy import select
from sqlalchemy.orm import Session
from common import database, models, utils

router = APIRouter()

from pydantic import BaseModel
from typing import List, Optional

class LoginBody(BaseModel):
    email: str
    password: str


@router.post("/create-test-user")
def create_test_user(
    db: Session = Depends(database.get_db)
):
    user = models.User(
        username="test",
        email="test@gmail.com",
        password="test"
    )

    db.add(user)
    db.commit()

    return {"message": "Utilisateur connecté"}


# LOGIN 
@router.post("/login")
def login(
    body: LoginBody,
    db: Session = Depends(database.get_db)
):
    query = select(models.User).where(models.User.email == body.email)
    user = db.execute(query).scalars().first()

    if (user == None):
        raise HTTPException(status_code=404, detail="User not found")

    if body.password != user.password:
        raise HTTPException(status_code=404, detail="Invalid credentials")

    print(user.id)

    return {
        "message": "Utilisateur connecté",
        "user_id": user.id
    }

