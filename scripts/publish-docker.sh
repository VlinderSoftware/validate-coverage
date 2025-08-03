#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo "Usage: $0 [version]"
    echo ""
    echo "Manually builds and pushes Docker image to GHCR."
    echo ""
    echo "Parameters:"
    echo "  version    Optional version tag (defaults to 'latest')"
    echo ""
    echo "Examples:"
    echo "  $0           # Pushes as 'latest'"
    echo "  $0 v1.0.0    # Pushes as 'v1.0.0' and 'latest'"
    echo ""
    echo "Prerequisites:"
    echo "  - Docker logged in to GHCR: docker login ghcr.io"
    echo "  - GitHub token with packages:write permission"
}

VERSION="${1:-latest}"
IMAGE_NAME="validate-coverage"
REGISTRY="ghcr.io"
REPO="vlindersoftware/validate-coverage"
FULL_IMAGE="$REGISTRY/$REPO"

log "Manual Docker image publication"
log "Version: $VERSION"
log "Registry: $REGISTRY"
log "Repository: $REPO"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    error "Docker is not running or accessible"
    exit 1
fi

# Check if logged in to GHCR
if ! docker system info | grep -q "ghcr.io"; then
    warning "You may not be logged in to GHCR"
    log "To log in: echo \$GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build the image
log "Building Docker image"
docker build -t "$IMAGE_NAME" .

# Test the image quickly
log "Quick test of built image"
if docker run --rm -v "$(pwd)/examples:/workspace" "$IMAGE_NAME" /workspace/clover.xml 80 clover >/dev/null; then
    success "Image test passed"
else
    error "Image test failed"
    exit 1
fi

# Tag for GHCR
if [ "$VERSION" != "latest" ]; then
    log "Tagging image with version: $VERSION"
    docker tag "$IMAGE_NAME" "$FULL_IMAGE:$VERSION"
fi

log "Tagging image as latest"
docker tag "$IMAGE_NAME" "$FULL_IMAGE:latest"

# Push to GHCR
if [ "$VERSION" != "latest" ]; then
    log "Pushing versioned image: $FULL_IMAGE:$VERSION"
    docker push "$FULL_IMAGE:$VERSION"
fi

log "Pushing latest image: $FULL_IMAGE:latest"
docker push "$FULL_IMAGE:latest"

success "Docker image published successfully!"
success "Image available at:"
if [ "$VERSION" != "latest" ]; then
    success "  - $FULL_IMAGE:$VERSION"
fi
success "  - $FULL_IMAGE:latest"

log ""
log "To use in GitHub Actions:"
log "  uses: vlindersoftware/validate-coverage@main"
log ""
log "Or update action.yml to reference the published image:"
log "  image: '$FULL_IMAGE:$VERSION'"
