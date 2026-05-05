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

if ! repo="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)"; then
  cat >&2 <<'EOF'
error: no GitHub remote found for this repo.

Create one and push, then re-run this script. For example:

  # Create a new GitHub repo from the current directory and push main:
  gh repo create <name> --private --source=. --remote=origin --push

  # Or, if the repo already exists on GitHub:
  git remote add origin git@github.com:<owner>/<name>.git
  git push -u origin main
EOF
  exit 1
fi
visibility="$(gh repo view --json visibility -q .visibility)"
echo "Configuring $repo ($visibility)..."

# Secret scanning, push protection, and branch protection are free for public
# repos; on private repos they require GitHub Advanced Security. If GHAS isn't
# enabled, skip everything and self-destruct — re-running later is unlikely.
if [ "$visibility" != "PUBLIC" ]; then
  ghas_status="$(gh api "repos/$repo" -q '.security_and_analysis.advanced_security.status' 2>/dev/null || true)"
  if [ "$ghas_status" != "enabled" ]; then
    echo "Skipping: $repo is $visibility and GitHub Advanced Security is not enabled." >&2
    rm -- "$0"
    exit 0
  fi
fi

# Secret scanning + push protection.
gh api -X PATCH "repos/$repo" \
  -F security_and_analysis[secret_scanning][status]=enabled \
  -F security_and_analysis[secret_scanning_push_protection][status]=enabled \
  >/dev/null

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
