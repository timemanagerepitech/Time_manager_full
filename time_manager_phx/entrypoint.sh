#!/bin/sh
set -e

# Default DB env names used in docker-compose.yml:
: "${POSTGRES_USER:=postgres}"
: "${POSTGRES_PASSWORD:=postgres}"
: "${POSTGRES_DB:=time_manager_db}"
: "${DB_HOST:=db}"

echo "Waiting for Postgres at $DB_HOST:5432 ..."

# Wait until Postgres is ready. Use PGPASSWORD for authentication.
until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' >/dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping 2s"
  sleep 2
done

echo "Postgres is up - running migrations"

# Create DB if not present, then migrate
mix ecto.create || true
mix ecto.migrate

echo "Starting Phoenix server"
# Start server (for prod use releases but this is simple & works)
mix phx.server
