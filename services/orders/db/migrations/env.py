import os
import sys
from logging.config import fileConfig

from sqlalchemy import engine_from_config
from sqlalchemy import pool
from sqlalchemy import text

from alembic import context

# Add the parent directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

# Import the SQLAlchemy models and database configuration
from config.database import Base, SQLALCHEMY_DATABASE_URL, DB_SCHEMA
from models.order import Order

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Override the sqlalchemy.url with our connection string
config.set_main_option("sqlalchemy.url", SQLALCHEMY_DATABASE_URL)

# Interpret the config file for Python logging.
# This line sets up loggers basically.
fileConfig(config.config_file_name)

# add your model's MetaData object here
# for 'autogenerate' support
target_metadata = Base.metadata

# other values from the config, defined by the needs of env.py,
# can be acquired:
# my_important_option = config.get_main_option("my_important_option")
# ... etc.


def run_migrations_offline():
    """Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well.  By skipping the Engine creation
    we don't even need a DBAPI to be available.

    Calls to context.execute() here emit the given string to the
    script output.

    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        include_schemas=True,
        version_table_schema=DB_SCHEMA
    )

    with context.begin_transaction():
        # Create schema if it doesn't exist - this is critical
        context.execute(text(f"CREATE SCHEMA IF NOT EXISTS {DB_SCHEMA}"))
        context.execute(text(f"SET search_path TO {DB_SCHEMA}, public"))
        
        # Run migrations
        context.run_migrations()


def run_migrations_online():
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine
    and associate a connection with the context.

    """
    # Create engine with explicit schema creation option
    engine_config = config.get_section(config.config_ini_section)
    engine_config["sqlalchemy.connect_args"] = {"options": f"-c search_path={DB_SCHEMA},public"}
    
    connectable = engine_from_config(
        engine_config,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        # First create schema in a separate transaction to ensure it exists
        connection.execute(text(f"CREATE SCHEMA IF NOT EXISTS {DB_SCHEMA}"))
        connection.execute(text("COMMIT"))
        
        # Then set search path and run migrations
        connection.execute(text(f"SET search_path TO {DB_SCHEMA}, public"))
        
        context.configure(
            connection=connection, 
            target_metadata=target_metadata,
            include_schemas=True,
            version_table_schema=DB_SCHEMA
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
