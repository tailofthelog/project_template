# Use the official Node.js 22 LTS image as base (Debian-based for apt-get)
FROM node:22-bookworm-slim@sha256:d415caac2f1f77b98caaf9415c5f807e14bc8d7bdea62561ea2fef4fbd08a73c

# Install system dependencies and shell tools
# 5/5/26 - Added poppler-utils for PDF parsing.
# 5/5/26 - Added pre-commit so the .pre-commit-config.yaml hook runs in-container.
RUN apt-get update && apt-get install -y \
    git bash curl python3 python3-pip poppler-utils pre-commit \
    && rm -rf /var/lib/apt/lists/*

#Add Gitleaks to Container to scan for secrets by default.
ARG GITLEAKS_VERSION=8.21.2
RUN curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
| tar -xz -C /usr/local/bin gitleaks \
&& gitleaks version

# Install Claude Code CLI globally, plus ccusage for the statusline.
RUN npm install -g @anthropic-ai/claude-code@2.1.126 ccusage

# Pinned version is intentional; the non-root sandbox user can't write to
# the global node_modules anyway, so auto-update would just emit warnings.
ENV DISABLE_AUTOUPDATER=1

# Create a non-root user
RUN useradd -m -s /bin/bash cc_sandbox
WORKDIR /home/cc_sandbox
USER cc_sandbox

# Set the default command to start an interactive session
CMD ["claude"]