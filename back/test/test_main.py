from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from main import app
from common.database import Base

client = TestClient(app)

SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool, # StaticPool so the db is not wiped after first test
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create the tables using the same Base as the real database
Base.metadata.create_all(bind=engine)


def get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
