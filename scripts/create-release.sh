#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored log messages
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

show_usage() {
    echo "Usage: $0 <version>"
    echo ""
    echo "Creates a new release for the validate-coverage action."
    echo ""
    echo "Parameters:"
    echo "  version    Version number in semver format (e.g., 1.2.3)"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0    # Creates v1.0.0 release"
    echo "  $0 1.2.3    # Creates v1.2.3 release"
    echo ""
    echo "Process:"
    echo "  1. Creates release/vN branch from main"
    echo "  2. Updates version references"
    echo "  3. Creates and pushes vX.Y.Z tag"
    echo "  4. GitHub Actions will build and publish the Docker image"
    echo "  5. Major (vN) and minor (vN.M) tags will be updated automatically"
}

# Validate input
if [ -z "$1" ]; then
    error "Version number is required"
    show_usage
    exit 1
fi

VERSION="$1"

# Validate version format (semver)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "Version must be in semver format (e.g., 1.2.3)"
    exit 1
fi

# Extract version parts
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)
PATCH=$(echo "$VERSION" | cut -d. -f3)

log "Preparing release v$VERSION"
log "Major: $MAJOR, Minor: $MINOR, Patch: $PATCH"

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    warning "You are not on the main branch (current: $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    error "You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Check if tag already exists
if git tag | grep -q "^v$VERSION$"; then
    error "Tag v$VERSION already exists"
    exit 1
fi

# Check if any of the convenience tags already exist
MAJOR_TAG="v$MAJOR"
MINOR_TAG="v$MAJOR.$MINOR"
FULL_TAG="v$VERSION"

if git tag | grep -q "^$MAJOR_TAG$"; then
    warning "Major tag $MAJOR_TAG already exists and will be updated"
fi

if git tag | grep -q "^$MINOR_TAG$"; then
    warning "Minor tag $MINOR_TAG already exists and will be updated"
fi

# Create release branch
RELEASE_BRANCH="release/v$MAJOR"
log "Creating release branch: $RELEASE_BRANCH"

# Check if release branch exists
if git branch -r | grep -q "origin/$RELEASE_BRANCH"; then
    log "Release branch already exists, checking out"
    git checkout "$RELEASE_BRANCH"
    git pull origin "$RELEASE_BRANCH"
else
    log "Creating new release branch"
    git checkout -b "$RELEASE_BRANCH"
fi

# Update version references in action.yml if needed
log "Updating action.yml image reference"
if grep -q "ghcr.io/vlindersoftware/validate-coverage" action.yml; then
    # Replace any existing version with the new version
    sed -i "s|ghcr.io/vlindersoftware/validate-coverage:[^'\"]*|ghcr.io/vlindersoftware/validate-coverage:v$VERSION|g" action.yml
    log "Updated action.yml to use image: ghcr.io/vlindersoftware/validate-coverage:v$VERSION"
    git add action.yml
    git commit -m "Update action to use v$VERSION image" || true
else
    warning "No GHCR image reference found in action.yml"
fi

# Push release branch
log "Pushing release branch"
git push -u origin "$RELEASE_BRANCH"

# Create and push tags (v1, v1.0, v1.0.0)
log "Creating tags: $MAJOR_TAG, $MINOR_TAG, $FULL_TAG"

# Create the full version tag
git tag "$FULL_TAG"

# Delete existing major/minor tags if they exist (to update them)
if git tag | grep -q "^$MAJOR_TAG$"; then
    log "Deleting existing major tag $MAJOR_TAG"
    git tag -d "$MAJOR_TAG" || true
    git push origin ":refs/tags/$MAJOR_TAG" || true
fi

if git tag | grep -q "^$MINOR_TAG$"; then
    log "Deleting existing minor tag $MINOR_TAG"
    git tag -d "$MINOR_TAG" || true
    git push origin ":refs/tags/$MINOR_TAG" || true
fi

# Create major and minor tags
git tag "$MAJOR_TAG"
git tag "$MINOR_TAG"

# Push all tags
log "Pushing tags to origin"
git push origin "$FULL_TAG"
git push origin "$MAJOR_TAG"
git push origin "$MINOR_TAG"

success "Release v$VERSION created successfully!"
success "Created and pushed tags:"
success "  - $FULL_TAG (full version)"
success "  - $MINOR_TAG (minor version convenience tag)"
success "  - $MAJOR_TAG (major version convenience tag)"
success ""
success "GitHub Actions will now:"
success "  1. Build and push Docker image to GHCR with tags:"
success "     - ghcr.io/vlindersoftware/validate-coverage:$FULL_TAG"
success "     - ghcr.io/vlindersoftware/validate-coverage:$MINOR_TAG"
success "     - ghcr.io/vlindersoftware/validate-coverage:$MAJOR_TAG"
success "     - ghcr.io/vlindersoftware/validate-coverage:latest"
success "  2. Create GitHub release"
success ""
success "The action.yml now references: ghcr.io/vlindersoftware/validate-coverage:v$VERSION"
success ""
success "Monitor the release at: https://github.com/VlinderSoftware/validate-coverage/actions"
success "Once complete, the action can be used as:"
success "  uses: vlindersoftware/validate-coverage@$FULL_TAG"
success "  uses: vlindersoftware/validate-coverage@$MINOR_TAG"
success "  uses: vlindersoftware/validate-coverage@$MAJOR_TAG"
