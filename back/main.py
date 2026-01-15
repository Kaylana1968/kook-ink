from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from common import database, models
from controller import recipe, login

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


app.include_router(recipe.router)
app.include_router(login.router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="10.0.2.2", port=8000, reload=True)
