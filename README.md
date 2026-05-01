# project_template

Starter scaffold for new projects that will be developed with Claude Code running inside a per-project Docker sandbox.

## What's in here

- `cc_docker/` — Dockerfile + compose file for running Claude Code in an isolated container with the project mounted. See [`cc_docker/README.md`](cc_docker/README.md).
- `CLAUDE.md` — project-specific instructions auto-loaded by Claude Code. Edit this for each new project.
- `bootstrap.sh` — run once after copying the template; severs template git history, starts a fresh repo, then deletes itself.

## Starting a new project

```bash
# Copy the template (don't clone — you don't want the template's git history)
cp -R /path/to/project_template my-new-project
cd my-new-project
./bootstrap.sh my-new-project
```

Then launch Claude in the sandbox:

```bash
docker compose -f cc_docker/docker-compose.yml run --rm claude
```

## Updating the template itself

This directory is itself a git repo. Commit changes here as you would any other repo. Existing projects won't pick up changes automatically — re-copy `cc_docker/` or specific files into them as needed.
