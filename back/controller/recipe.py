from fastapi import APIRouter, Depends, HTTPException
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
    
    
@router.patch("/recipe/{recipe_id}")
def update_recipe(recipe_id: int, db: Session = Depends(database.get_db)):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    
    recipe.description = "coucou"
    try:
        db.commit()
        db.refresh(recipe)
        return recipe
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")
    finally:
        db.close()

@router.delete("/recipe/{recipe_id}")
def delete_recipe(recipe_id: int, db: Session = Depends(database.get_db)):
    recipe = db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    db.delete(recipe)
    
    try:
        db.commit()
        print(f"Recipe deleted successfully with ID: {recipe.id}")
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")
    finally:
        db.close()

