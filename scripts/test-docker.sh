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

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

IMAGE_NAME="validate-coverage"

log "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

log "Testing Docker image with example coverage files"

# Test each format
FORMATS=("clover" "cobertura" "jacoco")
WORKSPACE_DIR="$(pwd)/examples"

for format in "${FORMATS[@]}"; do
    log "Testing $format format"
    
    if docker run --rm \
        -v "$WORKSPACE_DIR:/workspace" \
        "$IMAGE_NAME" \
        "/workspace/$format.xml" 80 "$format"; then
        success "$format format test passed"
    else
        error "$format format test failed"
        exit 1
    fi
done

log "Testing failure case (high threshold)"
if docker run --rm \
    -v "$WORKSPACE_DIR:/workspace" \
    "$IMAGE_NAME" \
    "/workspace/clover.xml" 95 "clover"; then
    error "Expected failure but got success"
    exit 1
else
    success "Failure case test passed (correctly failed)"
fi

success "All Docker tests passed!"
success "Image is ready for publishing"

log "To push to GHCR:"
log "  docker tag $IMAGE_NAME ghcr.io/vlindersoftware/validate-coverage:latest"
log "  docker push ghcr.io/vlindersoftware/validate-coverage:latest"
