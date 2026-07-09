# Release Process

Releases are automated by [release-please](https://github.com/googleapis/release-please)
based on [Conventional Commits](https://www.conventionalcommits.org/) merged to `main`.

## How it works

1. Every push to `main` runs `.github/workflows/release-please.yml`, which keeps
   an open "release PR" that accumulates a version bump and `CHANGELOG.md` entry
   for the unreleased commits (`fix:` → patch, `feat:` → minor, `feat!:` /
   `BREAKING CHANGE:` → major).
2. Merging that release PR triggers release-please to tag the merge commit and
   create a GitHub Release.
3. The `pin-release-branch` job then reproduces the version-pinning step that used
   to be done by the old `scripts/create-release.sh`:
   - resets/creates `release/vN` (N = the new major version) from the release commit
   - rewrites `action.yml` on that branch to pin the Docker image to the exact
     released version instead of `:latest`
   - force-moves the `vX.Y.Z`, `vX.Y`, and `vX` tags onto that pinned commit
4. `cd_tag_image.yml` (unchanged) reacts to the moved `vX.Y.Z` tag and promotes the
   already-built image to the release tags in `ghcr.io`.

`main`'s `action.yml` keeps referencing `:latest`, as before — only the release
branches and tags pin to a specific version.

## Usage

```yaml
# specific version (recommended for production)
- uses: vln-devsecops/actions-validate-coverage@v1.2.3

# minor version (gets patch updates)
- uses: vln-devsecops/actions-validate-coverage@v1.2

# major version (gets all v1.x.x updates)
- uses: vln-devsecops/actions-validate-coverage@v1
```

## Manual override

A specific version can still be forced by including a `Release-As: X.Y.Z` footer in
a commit message, which release-please picks up when computing the next release PR.

## Validation

After each release:
1. Monitor GitHub Actions: https://github.com/vln-devsecops/actions-validate-coverage/actions
2. Verify Docker images: https://github.com/vln-devsecops/actions-validate-coverage/pkgs/container/actions-validate-coverage
3. Test the action: `docker pull ghcr.io/vln-devsecops/actions-validate-coverage:1.2.3`
