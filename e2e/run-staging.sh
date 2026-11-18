#!/usr/bin/env bash
# Builds the production Docker image exactly as shipped (./Dockerfile), runs it on
# localhost:18080, runs the Playwright suite against it, then removes the container.
set -euo pipefail
cd "$(dirname "$0")/.."
docker build -t tour-of-heroes:staging .
docker rm -f tour-of-heroes-staging >/dev/null 2>&1 || true
docker run -d --name tour-of-heroes-staging -p 18080:80 tour-of-heroes:staging >/dev/null
trap 'docker rm -f tour-of-heroes-staging >/dev/null' EXIT
until curl -fs http://localhost:18080/ >/dev/null; do sleep 1; done
cd e2e
[ -d node_modules ] || npm install
BASE_URL=http://localhost:18080 npx playwright test
