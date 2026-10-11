#!/usr/bin/env bash
# Checks the site in Docker: HTML and CSS validation, then internal links and images.
# The same script runs locally and in CI.
set -euo pipefail

cd "$(dirname "$0")/.."

VNU_IMAGE="ghcr.io/validator/validator:24.10.17"
LYCHEE_IMAGE="lycheeverse/lychee:0.15.1"

echo "==> Validating HTML and CSS"
docker run --rm --platform linux/amd64 -v "$PWD/site:/site:ro" "$VNU_IMAGE" \
  vnu --also-check-css --skip-non-html --filterpattern '.*Trailing slash on void elements.*' /site

echo "==> Checking internal links and images"
docker run --rm -v "$PWD/site:/site:ro" -w /site "$LYCHEE_IMAGE" \
  --offline --no-progress --include-fragments '/site/**/*.html'

echo "==> All checks passed"
