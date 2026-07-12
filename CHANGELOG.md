# Changelog

## [1.1.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.0.18...v1.1.0) (2026-07-12)


### Features

* add opt-in commit-status publishing for coverage results ([4568786](https://github.com/vln-devsecops/actions-validate-coverage/commit/4568786255e2ad69231556f740ed26bd96e033b1))
* add portable JSON coverage report as an artifact-based alternative ([0452a0d](https://github.com/vln-devsecops/actions-validate-coverage/commit/0452a0d847627fc555f1e9f890eb52f4dad6a133))


### Bug Fixes

* address release-please review feedback ([7ed5bc3](https://github.com/vln-devsecops/actions-validate-coverage/commit/7ed5bc3714aebcfc6fcad5e44e0c8e527fa00b27))
* emit report-file relative to GITHUB_WORKSPACE, not a container path ([7d186c6](https://github.com/vln-devsecops/actions-validate-coverage/commit/7d186c6afc31559e39dd36611822b7118ce64f19))
* guard jq payload build so it can't abort the run under set -e ([2b867f2](https://github.com/vln-devsecops/actions-validate-coverage/commit/2b867f229ffa26dc5451851ba6f9d2aaa5b0b9bb))
