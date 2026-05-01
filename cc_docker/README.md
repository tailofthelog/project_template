# cc_docker

Sandboxed Claude Code container for this project. Drop this folder into any project to run Claude Code in an isolated environment with the project mounted read/write.

## Usage

From anywhere inside the project:

```bash
docker compose -f cc_docker/docker-compose.yml run --rm claude
```

First run will build the image and prompt you to log in to Claude. Credentials are written to `~/.claude/.credentials.json` on the host and reused on subsequent runs.

## What gets mounted

| Host | Container | Purpose |
| --- | --- | --- |
| `<project root>` (parent of `cc_docker/`) | `/home/cc_sandbox/project` | Your code, RW |
| `~/.claude` | `/home/cc_sandbox/.claude` | Claude config, credentials, transcripts |
| `~/.claude.json` | `/home/cc_sandbox/.claude.json` | Claude top-level config |

## Sandbox properties

- Non-root user (`cc_sandbox`)
- All Linux capabilities dropped
- `no-new-privileges` enabled
- Memory capped at 4GB, 512 pids, 2 CPUs
- `init: true` for proper signal handling

The container does **not** restrict outbound network. Your project files and `~/.claude` contents are fully readable by anything Claude runs. See the project owner's notes on threat model before assuming this is a hard sandbox.

## Gotchas

- If `~/.claude.json` doesn't exist on the host yet, Docker will create a directory at that path and break Claude Code. Run Claude on the host once first, or `touch ~/.claude.json` before the first container run.
- Files Claude creates in the project will be owned by uid 1000 on Linux hosts. Harmless on macOS Docker Desktop.
- Adjust `mem_limit` / `cpus` in `docker-compose.yml` if Claude's tasks need more headroom (e.g. running a dev server alongside).

## Updating

```bash
docker compose -f cc_docker/docker-compose.yml build --pull
```

Pulls the latest base image and reinstalls Claude Code.
