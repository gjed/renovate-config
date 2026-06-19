#!/usr/bin/env bash
# Wrapper script invoked by renovate.service
# Resolves the GitHub token at runtime via gh CLI
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE="ghcr.io/renovatebot/renovate"
RUNTIME="$(command -v podman 2>/dev/null || echo docker)"

TOKEN="$(gh auth token)"

exec "$RUNTIME" run --rm \
  -e RENOVATE_TOKEN="$TOKEN" \
  -e LOG_LEVEL=info \
  -e RENOVATE_CONFIG_FILE=/usr/src/app/config.js \
  -v "$REPO_DIR/config.js":/usr/src/app/config.js \
  "$IMAGE"
