#!/usr/bin/env bash
# Serves the site at http://localhost:8080 from Docker. Ctrl-C stops it.
set -euo pipefail

cd "$(dirname "$0")/.."

PORT="${PORT:-8080}"
echo "Ocean Bliss preview: http://localhost:${PORT}"
docker run --rm -p "${PORT}:80" -v "$PWD/site:/usr/share/nginx/html:ro" nginx:1.27-alpine
