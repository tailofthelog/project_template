#!/usr/bin/env bash
# Apply GitHub-side security settings to the current repo.
#
# Usage:
#   ./setup-repo.sh
#
# Run once after the GitHub remote exists. Enables secret scanning,
# push protection, and branch protection on main requiring the
# secrets-scan workflow to pass. Self-destructs on success.
#
# Requires: gh CLI authenticated against the target repo's owner.

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI not found. Install with: brew install gh" >&2
  exit 1
fi

repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
visibility="$(gh repo view --json visibility -q .visibility)"
echo "Configuring $repo ($visibility)..."

# Secret scanning + push protection.
# Free for public repos; private repos require GitHub Advanced Security.
if ! gh api -X PATCH "repos/$repo" \
  -F security_and_analysis[secret_scanning][status]=enabled \
  -F security_and_analysis[secret_scanning_push_protection][status]=enabled \
  >/dev/null 2>&1; then
  echo "warn: could not enable secret scanning (likely a private repo without GHAS). Skipping." >&2
fi

# Branch protection on main: require the secrets-scan workflow's gitleaks job to pass.
gh api -X PUT "repos/$repo/branches/main/protection" \
  -F required_status_checks[strict]=true \
  -F required_status_checks[contexts][]=gitleaks \
  -F enforce_admins=false \
  -F required_pull_request_reviews=null \
  -F restrictions=null \
  >/dev/null

echo "Done. Secret scanning + branch protection configured for $repo."

rm -- "$0"
