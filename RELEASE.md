# Release Instructions

This document describes how to create releases for the validate-coverage GitHub Action.

## Release Process Overview

Our release process follows semantic versioning and uses GitHub Container Registry (GHCR) to host Docker images.

### Release Strategy

- **Release Branches**: `release/vN` (where N is the major version)
- **Version Tags**: Full semver tags (`v1.2.3`) trigger releases
- **Convenience Tags**: Major (`v1`) and minor (`v1.2`) tags point to latest patch
- **Docker Images**: Published to `ghcr.io/vlindersoftware/validate-coverage`

### Version Lifecycle

1. **Development**: Work happens on `main` branch
2. **Release Branch**: Create `release/v1` for major version 1 releases
3. **Tagging**: Create `v1.2.3` tag to trigger release
4. **Auto-tagging**: CI automatically updates `v1` and `v1.2` tags
5. **Publication**: Docker image published to GHCR with multiple tags

## Creating a New Release

### Option 1: Using the Release Script (Recommended)

```bash
# Create a new release
./scripts/create-release.sh 1.2.3

# This will:
# 1. Create/checkout release/v1 branch
# 2. Update version references
# 3. Create and push v1.2.3 tag
# 4. Trigger GitHub Actions release workflow
```

### Option 2: Manual Process

1. **Create Release Branch** (if it doesn't exist):
   ```bash
   git checkout main
   git pull origin main
   git checkout -b release/v1
   git push -u origin release/v1
   ```

2. **Update Action Reference** (update action.yml):
   ```yaml
   runs:
     using: 'docker'
     image: 'ghcr.io/vlindersoftware/validate-coverage:v1.2.3'
   ```

3. **Commit and Tag**:
   ```bash
   git add action.yml
   git commit -m "Update action to use v1.2.3 image"
   git tag v1.2.3
   git push origin release/v1
   git push origin v1.2.3
   ```

**Important**: The action.yml file should always reference the specific version tag (`v1.2.3`), not `latest`. The release script automatically updates this reference.

## Release Workflow Details

The `.github/workflows/release.yml` workflow handles:

### Build Stage
- **Triggers**: Push to `release/v*` branches or `v*.*.*` tags
- **Actions**: 
  - Builds Docker image
  - Pushes to GHCR with multiple tags
  - Runs tests against built image

### Release Stage (Tag Pushes Only)
- **Triggers**: Only when `v*.*.*` tag is pushed
- **Actions**:
  - Updates major/minor version tags (e.g., `v1`, `v1.2`)
  - Creates GitHub release with changelog
  - Links to published Docker image

### Test Stage
- **Matrix Testing**: Tests all coverage formats (clover, cobertura, jacoco)
- **Validation**: Ensures Docker image works correctly

## Docker Image Tags

For version `v1.2.3`, the following tags are created:

| Tag | Purpose | Example | Used By |
|-----|---------|---------|---------|
| `v1.2.3` | Specific version | `ghcr.io/vlindersoftware/validate-coverage:v1.2.3` | Release action.yml |
| `v1.2` | Latest patch in minor | `ghcr.io/vlindersoftware/validate-coverage:v1.2` | Users with `@v1.2` |
| `v1` | Latest minor in major | `ghcr.io/vlindersoftware/validate-coverage:v1` | Users with `@v1` |
| `latest` | Latest overall release | `ghcr.io/vlindersoftware/validate-coverage:latest` | External references |
| `main` | Development version | `ghcr.io/vlindersoftware/validate-coverage:main` | Development action.yml |

**Important**: The action.yml in release branches always references the specific version tag (e.g., `v1.2.3`), ensuring reproducible builds and preventing unexpected updates.

## Usage After Release

Once released, users can reference the action in multiple ways:

```yaml
# Specific version (recommended for production)
- uses: vlindersoftware/validate-coverage@v1.2.3

# Latest in major version (gets auto-updates)
- uses: vlindersoftware/validate-coverage@v1

# Latest in minor version
- uses: vlindersoftware/validate-coverage@v1.2
```

## Version Compatibility

### Major Version Updates (v1 → v2)
- **Breaking Changes**: API changes, input/output changes
- **Migration**: Users must update workflows
- **Branch**: Create new `release/v2` branch

### Minor Version Updates (v1.1 → v1.2)
- **New Features**: Backward-compatible additions
- **Auto-update**: Users on `@v1` get updates automatically
- **Branch**: Use existing `release/v1` branch

### Patch Version Updates (v1.1.0 → v1.1.1)
- **Bug Fixes**: No API changes
- **Auto-update**: Users on `@v1` or `@v1.1` get updates
- **Branch**: Use existing `release/v1` branch

## Testing Before Release

Before creating a release:

1. **Local Testing**:
   ```bash
   # Build and test locally
   docker build -t validate-coverage .
   ./validate-coverage.sh examples/clover.xml 80
   ```

2. **Integration Testing**:
   ```bash
   # Test in a real workflow (create test repository)
   # Use the Docker image directly first
   ```

3. **Format Testing**:
   ```bash
   # Test all supported formats
   ./validate-coverage.sh examples/clover.xml 80 clover
   ./validate-coverage.sh examples/cobertura.xml 80 cobertura
   ./validate-coverage.sh examples/jacoco.xml 80 jacoco
   ```

## Troubleshooting Releases

### Failed Release Build
- Check GitHub Actions logs
- Verify Dockerfile builds locally
- Ensure all tests pass

### Failed Tag Update
- Check repository permissions
- Verify GITHUB_TOKEN has write access
- May need to manually fix tag conflicts

### Failed GHCR Push
- Verify package permissions in repository settings
- Check if organization allows GHCR publishing
- Verify GitHub token has `packages:write` permission

## Release Checklist

Before creating a release:

- [ ] All tests pass locally
- [ ] Docker image builds successfully
- [ ] Version number follows semver
- [ ] No uncommitted changes
- [ ] On correct branch (main or release/vN)
- [ ] Updated documentation if needed
- [ ] Reviewed changes since last release

After release:
- [ ] Verify GitHub release was created
- [ ] Confirm Docker image is in GHCR
- [ ] Test the released action in a sample workflow
- [ ] Update any documentation that references versions
- [ ] Announce release if significant

## Security Considerations

- **Token Scope**: GITHUB_TOKEN only has repository access
- **Image Scanning**: GHCR automatically scans images for vulnerabilities
- **Dependency Updates**: Keep Alpine base image and dependencies updated
- **Secrets**: Never include secrets in Docker image or logs

## Monitoring

After releases, monitor:

- **GitHub Marketplace**: Usage statistics and ratings
- **Download Metrics**: GHCR package download counts  
- **Issues**: User-reported bugs or feature requests
- **Security Alerts**: Dependabot and security advisories
