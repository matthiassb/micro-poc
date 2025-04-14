import os
import re
from urllib.parse import urlparse, parse_qs
from sqlalchemy import create_engine, MetaData, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Parse DATABASE_URL if provided, otherwise use individual environment variables
DATABASE_URL = os.environ.get('DATABASE_URL')
if DATABASE_URL:
    # Parse the DATABASE_URL to extract components
    parsed_url = urlparse(DATABASE_URL)
    
    # Extract username and password
    DB_USER = parsed_url.username or 'microservices'
    DB_PASSWORD = parsed_url.password or 'microservices'
    
    # Extract host and port
    DB_HOST = parsed_url.hostname or 'postgres'
    DB_PORT = str(parsed_url.port) if parsed_url.port else '5432'
    
    # Extract database name
    DB_NAME = parsed_url.path.lstrip('/') or 'microservices_db'
    
    # Extract schema from query parameters if present
    query_params = parse_qs(parsed_url.query)
    DB_SCHEMA = query_params.get('schema', ['orders'])[0]
    
    # Construct SQLAlchemy URL without the schema parameter
    SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
else:
    # Use individual environment variables as fallback
    DB_HOST = os.environ.get('DB_HOST', 'postgres')
    DB_PORT = os.environ.get('DB_PORT', '5432')
    DB_NAME = os.environ.get('DB_NAME', 'microservices_db')
    DB_USER = os.environ.get('DB_USER', 'microservices')
    DB_PASSWORD = os.environ.get('DB_PASSWORD', 'microservices')
    DB_SCHEMA = os.environ.get('DB_SCHEMA', 'orders')
    
    # SQLAlchemy connection URL
    SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Create engine with more robust connection settings
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={
        "options": f"-c search_path={DB_SCHEMA},public",
        "connect_timeout": 10
    },
    pool_pre_ping=True,  # Check connection validity before using it
    pool_recycle=300,    # Recycle connections every 5 minutes
)

# Create schema if it doesn't exist
def create_schema():
    try:
        with engine.begin() as conn:
            conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {DB_SCHEMA}"))
            print(f"Schema '{DB_SCHEMA}' created or verified")
    except Exception as e:
        print(f"Error creating schema: {e}")
        # Continue execution - migrations will try to create schema if needed

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create base class for models
Base = declarative_base()
metadata = MetaData(schema=DB_SCHEMA)

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
