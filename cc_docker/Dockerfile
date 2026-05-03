# Use the official Node.js 22 LTS image as base (Debian-based for apt-get)
FROM node:22-bookworm-slim@sha256:d415caac2f1f77b98caaf9415c5f807e14bc8d7bdea62561ea2fef4fbd08a73c

# Install system dependencies and shell tools
RUN apt-get update && apt-get install -y \
    git bash curl python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code@2.1.126

# Create a non-root user
RUN useradd -m -s /bin/bash cc_sandbox
WORKDIR /home/cc_sandbox
USER cc_sandbox

# Set the default command to start an interactive session
CMD ["claude"]
