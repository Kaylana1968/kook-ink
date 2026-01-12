from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime
from common import database, models

router = APIRouter()

@router.post("/recipe")
def upload_recipe(db: Session = Depends(database.get_db)):
    recipe = models.Recipe(
        description="Delicious Homemade Pasta",
        difficulty=3,
        image_link="https://example.com/pasta.jpg",
        video_link="https://example.com/pasta.mp4",
        user_id=1,
        created_at=datetime.utcnow()
    )
    db.add(recipe)

    try:
        db.commit()
        print(f"Recipe added successfully with ID: {recipe.id}")
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")
    finally:
        db.close()
