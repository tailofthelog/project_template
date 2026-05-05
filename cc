#!/usr/bin/env bash
# Launch Claude Code in the project's Docker sandbox.
set -euo pipefail
cd "$(dirname "$0")"
exec docker compose -f cc_docker/docker-compose.yml run --rm claude "$@"
