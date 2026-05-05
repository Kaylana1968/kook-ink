from fastapi import Depends
import jwt, os
from dotenv import load_dotenv
from passlib.context import CryptContext
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from common import models

load_dotenv()
secret_key = os.getenv("SECRET_KEY")

bearer_scheme = HTTPBearer()
optional_bearer_scheme = HTTPBearer(auto_error=False)
algorithm = "HS256"


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_user(authorization: HTTPAuthorizationCredentials = Depends(bearer_scheme)):
    return jwt.decode(authorization.credentials, secret_key, algorithms=[algorithm])


def get_optional_user(
    authorization: HTTPAuthorizationCredentials | None = Depends(optional_bearer_scheme),
):
    if authorization is None:
        return None

    try:
        return jwt.decode(authorization.credentials, secret_key, algorithms=[algorithm])
    except jwt.PyJWTError:
        return None


def generate_token(user: models.User):
    return jwt.encode({"id": str(user.id)}, secret_key, algorithm=algorithm)


def verify_password(password, hashed_password):
    return pwd_context.verify(password, hashed_password)


def hash_password(password: str):
    return pwd_context.hash(password)
