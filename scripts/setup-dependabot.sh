#!/bin/bash
# Script to configure repository settings for Dependabot auto-merge
# This should be run once to set up the repository properly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

REPO_OWNER="vlindersoftware"
REPO_NAME="vadidate-coverage"

log "Setting up repository configuration for Dependabot auto-merge"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    error "GitHub CLI (gh) is required but not installed"
    error "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    error "Please authenticate with GitHub CLI first:"
    error "  gh auth login"
    exit 1
fi

log "Enabling Dependabot security updates..."
gh api repos/$REPO_OWNER/$REPO_NAME/vulnerability-alerts \
    --method PUT \
    --silent || warn "Could not enable vulnerability alerts (may already be enabled)"

log "Enabling Dependabot version updates..."
# Dependabot config is handled by .github/dependabot.yml file

log "Configuring branch protection for main branch..."
gh api repos/$REPO_OWNER/$REPO_NAME/branches/main/protection \
    --method PUT \
    --field required_status_checks='{"strict":true,"checks":[{"context":"test","app_id":null}]}' \
    --field enforce_admins=false \
    --field required_pull_request_reviews='{"required_approving_review_count":0,"dismiss_stale_reviews":false,"require_code_owner_reviews":false,"require_last_push_approval":false}' \
    --field restrictions=null \
    --field allow_auto_merge=true \
    --field allow_deletions=false \
    --field allow_force_pushes=false \
    --silent || warn "Could not configure branch protection (check repository permissions)"

log "Configuring branch protection pattern for release branches..."
# Note: GitHub API doesn't directly support wildcard branch protection via API
# This would need to be done manually in the repository settings
warn "Please manually configure branch protection for pattern 'release/v*' with same settings as main"

log "Enabling auto-merge for the repository..."
gh api repos/$REPO_OWNER/$REPO_NAME \
    --method PATCH \
    --field allow_auto_merge=true \
    --silent || warn "Could not enable auto-merge (may require admin permissions)"

success "Repository configuration completed!"
success ""
success "Dependabot is now configured to:"
success "  • Check for GitHub Actions updates weekly (main) and daily (release branches)"
success "  • Check for Docker base image updates weekly (main) and daily (release branches)"
success "  • Auto-merge PRs when all checks pass"
success "  • Prioritize security updates"
success "  • Auto-bump patch versions on release branches"
success ""
log "Next steps:"
log "  1. Ensure you have appropriate permissions on the repository"
log "  2. Set up branch protection for 'release/v*' pattern manually in repository settings"
log "  3. Create release branches using: ./scripts/create-release-branch.sh <major>"
log "  4. Dependabot will start creating PRs according to the schedule"
log "  5. PRs will auto-merge when the 'test' check passes"
log "  6. Patch versions will be automatically created on release branches"
