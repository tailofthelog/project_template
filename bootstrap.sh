#!/usr/bin/env bash
# Convert a copy of project_template into a fresh project repo.
#
# Usage:
#   ./bootstrap.sh [project-name]
#
# Run this once, from inside the new project directory, after copying or
# cloning project_template. It severs the template's git history, starts a
# fresh repo, and removes itself.

set -euo pipefail

if [[ ! -d cc_docker ]]; then
  echo "error: run this from the project root (cc_docker/ not found)" >&2
  exit 1
fi

project_name="${1:-$(basename "$PWD")}"

# Drop template git history.
rm -rf .git

# Fresh repo.
git init -q -b main
git add -A
git commit -q -m "Initial commit from project_template"

# Self-destruct so it doesn't ship with the new project.
rm -- "$0"

echo "Initialized '$project_name' as a new git repo."
echo "Next: docker compose -f cc_docker/docker-compose.yml run --rm claude"
