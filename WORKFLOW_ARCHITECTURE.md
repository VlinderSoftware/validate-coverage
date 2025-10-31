# Workflow Architecture Summary

## Current Coherent Workflow Setup

### 1. Main Branch Workflows

**`main-push.yml`** - Triggers on: `push to main`
- Runs tests and validation
- Builds development Docker image (`:main` tag)
- **Auto-corrects action.yml** to use `:latest` if needed
- Permissions: `contents: write, packages: write`

**`autoversion-release.yml`** - Triggers on: `push to main`, `dependabot PRs to main`
- Uses autoversion for semantic releases
- Only affects main branch now (removed release branch triggers)
- Permissions: `contents: write, packages: write, pull-requests: write`

### 2. Release Branch Workflows

**`auto-release.yml`** - Triggers on: `push to release/v*`
- **NEW**: Main automated release workflow
- Determines version, updates action.yml, creates tags atomically
- Calls `release-tags.yml` for Docker build
- Permissions: `contents: write, packages: write`

**`release-branch-push.yml`** - Triggers on: `push to release/v*`
- **SIMPLIFIED**: Only runs tests and validation
- No longer does builds (delegated to auto-release.yml)
- Permissions: `contents: read, packages: read`

### 3. Tag-Based Workflows

**`release-tags.yml`** - Triggers on: `push tags v*.*.*`
- Builds and publishes Docker images
- Creates GitHub releases
- Called by auto-release.yml workflow
- Permissions: `contents: write, packages: write`

### 4. Validation Workflows

**`validate-action.yml`** - Triggers on: `action.yml changes`
- Validates action.yml format and Docker image availability
- **PROTECTED**: Skips github-actions bot commits to avoid loops
- Ensures main uses `latest`, releases use pinned versions
- Permissions: `contents: read`

**`test.yml`** - Reusable workflow
- Called by other workflows for testing
- Tests script and Docker functionality

### 5. PR and Other Workflows

**`pr-checks.yml`** - PR validation
**`dependabot-*.yml`** - Dependabot automation
**`auto-merge.yml`, `auto-bump-patch.yml`** - Automation helpers

## Workflow Sequence for Releases

### Manual Release Process:
```bash
git push origin main:release/v1
```

1. **`auto-release.yml`** triggers
   - Determines next version (e.g., 1.2.3)
   - Updates action.yml to pin to 1.2.3
   - Creates tags v1.2.3, v1.2, v1 on same commit
   - Calls `release-tags.yml`

2. **`release-tags.yml`** triggers (from tag push)
   - Builds Docker image with tags: 1.2.3, 1.2, 1, latest
   - Creates GitHub release

3. **`validate-action.yml`** runs (if triggered)
   - Validates the pinned version exists in GHCR

### Back to Main:
When changes merge back to main:

1. **`main-push.yml`** triggers
   - Auto-corrects action.yml back to `:latest`
   - Builds dev image

## Key Coherence Features

✅ **No Conflicts**: Each workflow has clear, non-overlapping responsibilities
✅ **Atomic Updates**: action.yml and tags are updated in same commit
✅ **Loop Prevention**: Bot commits are filtered out of validation
✅ **Proper Permissions**: Each workflow has minimum required permissions
✅ **Fallback Safety**: Multiple validation layers prevent broken releases
✅ **Clear Separation**: Dev (main) vs Release (branches) workflows are distinct

## Removed Conflicts

❌ **autoversion-release.yml**: No longer triggers on release branches
❌ **release-branch-push.yml**: No longer does builds/releases
❌ **validate-action.yml**: Skips bot commits to prevent loops
❌ **Duplicate triggers**: Each event has one primary handler

This architecture ensures reliable, automated releases while maintaining proper version management and preventing the "manifest unknown" errors.