#!/bin/bash
set -e

# Extract host and port from DATABASE_URL if it exists
if [ ! -z "$DATABASE_URL" ]; then
  # Extract host and port using regex
  DB_HOST=$(echo $DATABASE_URL | sed -E "s/^.*:\/\/[^:]+:[^@]+@([^:]+).*$/\\1/")
  DB_PORT=$(echo $DATABASE_URL | sed -E "s/^.*:\/\/[^:]+:[^@]+@[^:]+:([0-9]+).*$/\\1/")
fi

# Wait for PostgreSQL to be ready
wait-for-it.sh ${DB_HOST:-postgres}:${DB_PORT:-5432} -t 60

# Run database migrations
echo "Creating schema and running migrations..."
alembic upgrade head

echo "Migrations completed successfully!"
