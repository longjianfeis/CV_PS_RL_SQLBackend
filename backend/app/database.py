import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

load_dotenv(encoding='utf-8')

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:13689282250@localhost:5432/resumedb"
)

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()