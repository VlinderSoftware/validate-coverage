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
   - force-moves the floating `vX.Y` and `vX` tags onto that pinned commit

   The exact-version tag (`vX.Y.Z`) is left where release-please created it, on
   `main`. It used to be force-moved onto the pinned commit too, but that made
   it unreachable from `main`'s history, which broke release-please's own
   "commits since last release" bookkeeping — every subsequent run treated the
   whole history as unreleased and re-proposed it (see #24). One consequence:
   `@vX.Y.Z` no longer resolves to the pinned image reference, only the
   floating `vX.Y` / `vX` tags do (see Usage below).
4. The `tag-image` job (in the same run) calls `_promote_image.yml`, which builds
   the released image from source, tests it, and publishes the `X.Y.Z`, `X.Y`,
   `X`, and (for the highest release) `latest` tags to `ghcr.io`.

   > This promotion runs inside the release-please workflow on purpose. The
   > release tags are moved with the default `GITHUB_TOKEN`, and GitHub does not
   > start an `on: push: tags` workflow from a `GITHUB_TOKEN` push, so a separate
   > tag-triggered workflow would silently never run. To (re)publish the image
   > for an existing tag manually, run the **Promote release image** workflow
   > (`workflow_dispatch`) and give it the tag, e.g. `v1.2.0`.

`main`'s `action.yml` keeps referencing `:latest`, as before — only the release
branches and tags pin to a specific version.

## Usage

```yaml
# minor version (recommended for production: gets patch updates, pinned image)
- uses: vln-devsecops/actions-validate-coverage@v1.2

# major version (gets all v1.x.x updates, pinned image)
- uses: vln-devsecops/actions-validate-coverage@v1

# exact version (no automatic updates; does not pin the container image — for full reproducibility, pin to the commit SHA on the corresponding `release/vN` branch)
# - uses: vln-devsecops/actions-validate-coverage@<commit-sha>
- uses: vln-devsecops/actions-validate-coverage@v1.2.3
```

## Manual override

A specific version can still be forced by including a `Release-As: X.Y.Z` footer in
a commit message, which release-please picks up when computing the next release PR.

## Validation

After each release:
1. Monitor GitHub Actions: https://github.com/vln-devsecops/actions-validate-coverage/actions
2. Verify Docker images: https://github.com/vln-devsecops/actions-validate-coverage/pkgs/container/actions-validate-coverage
3. Test the action: `docker pull ghcr.io/vln-devsecops/actions-validate-coverage:1.2.3`
