# Automated Release Process

This repository now has a fully automated release process that triggers when you push to release branches.

## How it works

### 1. Release Branch Strategy

- **Main branch**: Always uses `latest` Docker image tag
- **Release branches**: Named `release/vN` (e.g., `release/v1`, `release/v2`)
- **Automatic versioning**: Patch versions are auto-incremented based on commits

### 2. Automated Release Flow

When you push to a release branch (e.g., `release/v1`):

1. **Version Determination**: 
   - Extracts major version from branch name
   - Finds latest tag for that major version
   - Auto-increments patch version based on new commits

2. **Action Update**:
   - Updates `action.yml` to pin to the specific version (e.g., `1.2.3`)
   - Commits the change back to the release branch

3. **Tag Creation**:
   - Creates version tag (e.g., `v1.2.3`)
   - Updates convenience tags (`v1`, `v1.2`)

4. **Docker Build & Release**:
   - Builds and publishes Docker image with proper tags
   - Creates GitHub release with release notes

### 3. Usage Examples

#### Creating a new release

```bash
# Make your changes on main branch
git checkout main
# ... make changes ...
git commit -m "feat: add new feature"

# Push to release branch to trigger automated release
git push origin main:release/v1
```

#### The automation will:
- Determine this should be version `1.2.3` (if `1.2.2` was the latest)
- Update `action.yml` to use `docker://ghcr.io/vlindersoftware/validate-coverage:1.2.3`
- Create tags: `v1.2.3`, `v1.2`, `v1`
- Build and publish Docker image
- Create GitHub release

#### Using the released action:

```yaml
# Use specific version (recommended for production)
- uses: vlindersoftware/validate-coverage@v1.2.3

# Use minor version (gets patch updates)
- uses: vlindersoftware/validate-coverage@v1.2

# Use major version (gets all updates for v1.x.x)
- uses: vlindersoftware/validate-coverage@v1
```

### 4. Workflow Files

- **`.github/workflows/auto-release.yml`**: Main automated release workflow
- **`.github/workflows/main-push.yml`**: Ensures main branch uses `latest`
- **`.github/workflows/release-branch-push.yml`**: Validation for release branches
- **`.github/workflows/validate-action.yml`**: Validates action.yml format and Docker images

### 5. Manual Override

If you need to create a specific version manually:

```bash
# Create and push a specific tag
git tag v1.3.0
git push origin v1.3.0

# This will trigger the existing release-tags.yml workflow
```

### 6. Rollback Strategy

If a release fails or needs rollback:

1. **Delete the problematic tag**:
   ```bash
   git tag -d v1.2.3
   git push origin :refs/tags/v1.2.3
   ```

2. **Fix the issue on the release branch**

3. **Push again to trigger a new release**

### 7. Branch Protection

The automation ensures:
- Main branch always uses `latest` tag
- Release branches always use pinned versions
- Docker images exist before allowing commits
- Action syntax is validated

This prevents the "manifest unknown" errors that occurred previously.