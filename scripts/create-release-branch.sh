#!/bin/bash
# Script to create a new release branch for a major version
# Usage: ./scripts/create-release-branch.sh 1

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

# Check if version is provided
if [ $# -ne 1 ]; then
    error "Usage: $0 <major>"
    error "Example: $0 1"
    exit 1
fi

MAJOR_VERSION="$1"
BRANCH_NAME="release/v$MAJOR_VERSION"

# Validate version format (should be major only)
if ! echo "$MAJOR_VERSION" | grep -qE '^[0-9]+$'; then
    error "Version must be a major version number (e.g., 1, 2, 3)"
    exit 1
fi

log "Creating release branch: $BRANCH_NAME"

# Ensure we're on main and up to date
log "Switching to main branch and pulling latest changes"
git checkout main
git pull origin main

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    error "Branch $BRANCH_NAME already exists locally"
    exit 1
fi

if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
    error "Branch $BRANCH_NAME already exists on remote"
    exit 1
fi

# Create the release branch
log "Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

# Update action.yml to use a version-specific tag instead of main
log "Updating action.yml to use version-specific Docker image"
INITIAL_TAG="$MAJOR_VERSION.0.0"
sed -i "s|image: 'docker://ghcr.io/vlindersoftware/validate-coverage:main'|image: 'docker://ghcr.io/vlindersoftware/validate-coverage:$INITIAL_TAG'|" action.yml

# Commit the change
git add action.yml
git commit -m "chore: initialize release branch v$MAJOR_VERSION

- Updated action.yml to use version-specific Docker image tag
- Prepared for v$MAJOR_VERSION.x.x releases"

# Push the branch
log "Pushing branch to origin"
git push -u origin "$BRANCH_NAME"

success "Release branch $BRANCH_NAME created successfully!"
success ""
success "Next steps:"
success "  1. The branch is ready for v$MAJOR_VERSION.x.x releases"
success "  2. Dependabot will now create PRs for this branch daily"
success "  3. Auto-merged PRs will create patch versions (v$MAJOR_VERSION.0.0, v$MAJOR_VERSION.0.1, etc.)"
success "  4. Use './scripts/create-release.sh $INITIAL_TAG' to create the first release"
success ""
log "Branch protection and Dependabot will automatically handle:"
log "  • Daily dependency updates"
log "  • Automatic PR merging when tests pass"
log "  • Patch version bumping after each merge"
