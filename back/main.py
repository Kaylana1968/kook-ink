from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
import models, database

app = FastAPI()


def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.on_event("startup")
def on_startup():
    models.Base.metadata.create_all(bind=database.engine)


@app.get("/users")
def read_user(db: Session = Depends(get_db)):
    user = db.query(models.User).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
