from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from common import database, models
from controller import recipe

app = FastAPI()


@app.on_event("startup")
def on_startup():
    models.Base.metadata.create_all(bind=database.engine)


@app.get("/users")
def read_user(db: Session = Depends(database.get_db)):
    user = db.query(models.User).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user


app.include_router(recipe.router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
