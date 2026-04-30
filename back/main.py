from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from common import database, models
from controller import recipe, login, post, profile, favorite, home, forum, like, comment

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    models.Base.metadata.create_all(bind=database.engine)

@app.get("/users")
def read_user(db: Session = Depends(database.get_db)):
    user = db.query(models.User).first()

    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    return user

app.include_router(login.router)
app.include_router(recipe.router)
app.include_router(post.router)
app.include_router(profile.router)
app.include_router(favorite.router)
app.include_router(home.router)
app.include_router(forum.router)
app.include_router(like.router)
app.include_router(comment.router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
