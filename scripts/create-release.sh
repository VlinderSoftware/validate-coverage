#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

prompt() {
    echo -e "${CYAN}[PROMPT]${NC} $1"
}

show_usage() {
    echo "Usage: $0 [version]"
    echo ""
    echo "Creates a new release for the validate-coverage action."
    echo ""
    echo "Parameters:"
    echo "  version    Optional. Version number in semver format (e.g., 1.2.3)"
    echo "             If not provided, script will suggest next versions"
    echo ""
    echo "Examples:"
    echo "  $0          # Interactive mode - suggests next versions"
    echo "  $0 1.2.3    # Creates v1.2.3 release directly"
    echo ""
    echo "Requirements:"
    echo "  - Must be run from main branch"
    echo "  - Working directory must be clean"
    echo "  - Main branch must be up to date with origin"
}

# Function to get the latest version tag
get_latest_version() {
    git tag -l 'v*.*.*' | sort -V | tail -n 1 | sed 's/^v//'
}

# Function to suggest next versions
suggest_versions() {
    local current_version="$1"
    
    if [ -z "$current_version" ]; then
        echo "1.0.0"
        return
    fi
    
    local major=$(echo "$current_version" | cut -d. -f1)
    local minor=$(echo "$current_version" | cut -d. -f2)
    local patch=$(echo "$current_version" | cut -d. -f3)
    
    echo "$major.$minor.$((patch + 1))"
    echo "$major.$((minor + 1)).0"
    echo "$((major + 1)).0.0"
}

# Function to check if on main branch
check_main_branch() {
    local current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        error "This script must be run from the main branch"
        error "Current branch: $current_branch"
        error "Please run: git checkout main"
        exit 1
    fi
}

# Function to check working directory is clean
check_clean_working_dir() {
    if ! git diff-index --quiet HEAD; then
        error "You have uncommitted changes. Please commit or stash them first."
        git status --short
        exit 1
    fi
}

# Function to ensure main is up to date
ensure_main_updated() {
    log "Fetching latest changes from origin..."
    git fetch origin
    
    local local_main=$(git rev-parse main)
    local remote_main=$(git rev-parse origin/main)
    
    if [ "$local_main" != "$remote_main" ]; then
        if git merge-base --is-ancestor main origin/main; then
            log "Updating local main branch..."
            git merge --ff-only origin/main
        else
            error "Local main branch has diverged from remote"
            error "Please resolve this manually before creating a release"
            exit 1
        fi
    fi
}

# Main script logic
main() {
    echo ""
    log "🚀 Validate Coverage Release Script"
    echo ""
    
    # Initial checks
    check_main_branch
    check_clean_working_dir
    ensure_main_updated
    
    # Get current version
    local current_version=$(get_latest_version)
    if [ -n "$current_version" ]; then
        log "Current version: v$current_version"
    else
        log "No previous versions found"
    fi
    
    # Handle version selection
    local VERSION
    if [ -n "$1" ]; then
        # Version provided as argument
        VERSION="$1"
        log "Using provided version: $VERSION"
    else
        # Interactive mode - suggest versions
        echo ""
        prompt "Select next version:"
        echo ""
        
        local suggestions=($(suggest_versions "$current_version"))
        
        # Display patch option
        echo -e "${CYAN}1)${NC} (patch)  ${suggestions[0]}"
        echo -e "${CYAN}2)${NC} (minor)  ${suggestions[1]}"
        echo -e "${CYAN}3)${NC} (major)  ${suggestions[2]}"
        echo ""
        echo -e "${CYAN}4)${NC} (custom) Enter custom version"
        echo ""
        
        read -p "Choose option (1-4): " choice
        echo ""
        
        case "$choice" in
            1)
                VERSION="${suggestions[0]}"
                log "Selected patch version: $VERSION"
                ;;
            2)
                VERSION="${suggestions[1]}"
                log "Selected minor version: $VERSION"
                ;;
            3)
                VERSION="${suggestions[2]}"
                log "Selected major version: $VERSION"
                ;;
            4)
                read -p "Enter custom version (e.g., 1.2.3): " VERSION
                log "Using custom version: $VERSION"
                ;;
            *)
                error "Invalid selection"
                exit 1
                ;;
        esac
    fi
    
    # Validate version format
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Version must be in semver format (e.g., 1.2.3)"
        exit 1
    fi
    
    # Check if tag already exists
    if git tag | grep -q "^v$VERSION$"; then
        error "Tag v$VERSION already exists"
        exit 1
    fi
    
    # Extract version parts
    local MAJOR=$(echo "$VERSION" | cut -d. -f1)
    local MINOR=$(echo "$VERSION" | cut -d. -f2)
    local PATCH=$(echo "$VERSION" | cut -d. -f3)
    
    echo ""
    log "Creating release v$VERSION (Major: $MAJOR, Minor: $MINOR, Patch: $PATCH)"
    
    # Confirm before proceeding
    echo ""
    read -p "Proceed with release v$VERSION? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Release cancelled"
        exit 0
    fi
    
    echo ""
    log "Starting release process..."
    
    # Create release branch
    local RELEASE_BRANCH="release/v$MAJOR"
    log "Creating/updating release branch: $RELEASE_BRANCH"
    
    # Check if release branch exists remotely
    if git ls-remote --heads origin "$RELEASE_BRANCH" | grep -q "$RELEASE_BRANCH"; then
        log "Release branch exists, updating from main"
        if git branch | grep -q "^[ *] $RELEASE_BRANCH$"; then
            git checkout "$RELEASE_BRANCH"
        else
            git checkout -b "$RELEASE_BRANCH" "origin/$RELEASE_BRANCH"
        fi
        # Reset to main to keep it in sync
        git reset --hard origin/main
    else
        log "Creating new release branch from main"
        git checkout -b "$RELEASE_BRANCH"
    fi
    
    # Update action.yml to reference the specific version
    log "Updating action.yml to reference version $VERSION"
    sed -i "s|docker://ghcr.io/vlindersoftware/validate-coverage:[^'\"]*|docker://ghcr.io/vlindersoftware/validate-coverage:$VERSION|g" action.yml
    
    git add action.yml
    git commit -m "chore: Update action.yml to reference $VERSION"
    
    # Push release branch
    log "Pushing release branch"
    git push origin "$RELEASE_BRANCH" --force
    
    # Create tags
    local MAJOR_TAG="v$MAJOR"
    local MINOR_TAG="v$MAJOR.$MINOR"
    local FULL_TAG="v$VERSION"
    
    log "Creating tags: $FULL_TAG, $MINOR_TAG, $MAJOR_TAG"
    
    # Delete existing convenience tags if they exist
    for tag in "$MAJOR_TAG" "$MINOR_TAG"; do
        if git tag | grep -q "^$tag$"; then
            git tag -d "$tag" 2>/dev/null || true
            git push origin ":refs/tags/$tag" 2>/dev/null || true
        fi
    done
    
    # Create all tags on current commit
    git tag "$FULL_TAG"
    git tag "$MINOR_TAG"
    git tag "$MAJOR_TAG"
    
    # Push all tags
    log "Pushing tags"
    git push origin "$FULL_TAG" "$MINOR_TAG" "$MAJOR_TAG"
    
    # Switch back to main and ensure action.yml uses latest
    log "Switching back to main branch"
    git checkout main
    
    log "Ensuring action.yml on main uses 'latest'"
    sed -i "s|docker://ghcr.io/vlindersoftware/validate-coverage:[^'\"]*|docker://ghcr.io/vlindersoftware/validate-coverage:latest|g" action.yml
    
    if ! git diff-index --quiet HEAD; then
        git add action.yml
        git commit -m "chore: Reset action.yml to use latest on main"
        git push origin main
    fi
    
    echo ""
    success "🎉 Release v$VERSION created successfully!"
    echo ""
    success "✅ Created and pushed:"
    success "   • Release branch: $RELEASE_BRANCH"
    success "   • Tags: $FULL_TAG, $MINOR_TAG, $MAJOR_TAG"
    success "   • Updated action.yml on release branch"
    success "   • Reset action.yml to 'latest' on main"
    echo ""
    success "📦 GitHub Actions will now build and publish:"
    success "   • Docker images with version tags"
    success "   • GitHub release with notes"
    echo ""
    success "🔍 Monitor progress at:"
    success "   https://github.com/vlindersoftware/validate-coverage/actions"
    echo ""
    success "📋 Once complete, the action can be used as:"
    success "   uses: vlindersoftware/validate-coverage@v$VERSION"
    success "   uses: vlindersoftware/validate-coverage@v$MAJOR.$MINOR"  
    success "   uses: vlindersoftware/validate-coverage@v$MAJOR"
    echo ""
}

# Parse command line arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_usage
    exit 0
fi

# Run main function
main "$@"
