#!/usr/bin/env bash
# Builds the production Docker image exactly as shipped (./Dockerfile), runs it on
# localhost:${STAGING_PORT:-18480}, runs the Playwright suite against it, then removes the container.
set -euo pipefail
PORT="${STAGING_PORT:-18480}"
cd "$(dirname "$0")/.."
docker build -t tour-of-heroes:staging .
docker rm -f tour-of-heroes-staging >/dev/null 2>&1 || true
docker run -d --name tour-of-heroes-staging -p "$PORT:80" tour-of-heroes:staging >/dev/null
trap 'docker rm -f tour-of-heroes-staging >/dev/null' EXIT
until curl -fs "http://localhost:$PORT/" >/dev/null; do sleep 1; done
cd e2e
[ -d node_modules ] || npm install
BASE_URL="http://localhost:$PORT" npx playwright test
