#!/bin/bash
set -e

echo ">>> Waiting for Postgres..."
while ! pg_isready -q -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do
  sleep 2
done

echo ">>> Running migrations..."
bin/chrono_pulse eval "ChronoPulse.Release.migrate"

echo ">>> Starting app..."
exec "$@"
