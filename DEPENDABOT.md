# Dependabot Configuration

This repository is configured with Dependabot to automatically manage dependency updates and security patches.

## What's Configured

### Dependabot Updates
- **GitHub Actions**: 
  - Weekly updates on main branch (Mondays at 9:00 AM)
  - Daily updates on release branches (9:00 AM)
- **Docker**: 
  - Weekly updates on main branch (Mondays at 9:00 AM)
  - Daily updates on release branches (9:00 AM)
- **Open PRs Limit**: 10 for Actions (main), 5 for Actions (release), 5 for Docker (main), 3 for Docker (release)
- **Auto-labeling**: `dependencies`, `github-actions`, `docker`, `release-branch`

### Auto-merge Behavior
Dependabot PRs will be automatically merged when:
- All required status checks pass (specifically the `test` workflow)
- The PR is created by `dependabot[bot]`
- No merge conflicts exist

### Patch Version Auto-bumping
On release branches (`release/v*`):
- When a Dependabot PR is auto-merged, a new patch version is automatically created
- Example: If on `release/v1` branch and current latest tag is `v1.0.3`, merging a dependency update creates `v1.0.4`
- The `action.yml` file is updated to reference the new version tag
- A GitHub release is automatically created
- Docker image is built and published with the new tag

### Security Updates
- Security-related PRs get special treatment with `security` and `priority-high` labels
- Security updates are auto-merged with higher priority
- Special notifications are added to security update PRs

## Workflows

### `.github/workflows/enable-auto-merge.yml`
- Runs when Dependabot opens a PR on main or release branches
- Enables GitHub's auto-merge feature
- Adds informational comment with branch-specific details

### `.github/workflows/dependabot-security.yml`
- Handles security-specific updates on main and release branches
- Adds priority labels
- Provides security notifications

### `.github/workflows/auto-merge-dependabot.yml` (Alternative)
- Manual implementation of auto-merge for main and release branches
- Waits for checks to complete
- Merges with squash commit

### `.github/workflows/auto-bump-patch.yml`
- Triggers when Dependabot PRs are merged on release branches
- Automatically increments patch version
- Updates action.yml with new version tag
- Creates GitHub release and triggers Docker build
- Comments on merged PR with release information

## Setup

To set up Dependabot auto-merge for this repository:

1. Run the setup script:
   ```bash
   ./scripts/setup-dependabot.sh
   ```

2. Create release branches for version-specific maintenance:
   ```bash
   ./scripts/create-release-branch.sh 1  # Creates release/v1 branch
   ```

3. Ensure you have the following repository settings:
   - Branch protection enabled on `main` and `release/v*` pattern
   - Required status check: `test`
   - Auto-merge enabled
   - Dependabot security updates enabled

## Release Branch Workflow

1. **Create Release Branch**: Use `./scripts/create-release-branch.sh <major>`
2. **Dependabot Updates**: Daily dependency updates on release branches
3. **Auto-merge**: PRs merge automatically when tests pass
4. **Patch Bumping**: Each merge creates a new patch version (e.g., v1.0.0 → v1.0.1)
5. **Docker Publishing**: New Docker images published automatically

## Manual Override

If you need to prevent auto-merge for a specific Dependabot PR:
1. Add a `do-not-merge` label to the PR
2. Or convert the PR to draft status
3. Or disable auto-merge for that specific PR

## Monitoring

- Check the **Actions** tab for workflow execution
- Monitor **Security** tab for vulnerability alerts
- Review **Pull requests** for Dependabot activity

## Customization

To modify Dependabot behavior:
- Edit `.github/dependabot.yml` for update schedules and packages
- Modify the auto-merge workflows in `.github/workflows/`
- Update the setup script if repository settings need changes
