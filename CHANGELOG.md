# Changelog

## [1.4.2](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.4.1...v1.4.2) (2026-08-25)


### Bug Fixes

* publish commit status to the PR head SHA, not the merge commit ([#41](https://github.com/vln-devsecops/actions-validate-coverage/issues/41)) ([7d46284](https://github.com/vln-devsecops/actions-validate-coverage/commit/7d46284825e81b0e12ad5f95351c65709a63b1bf))
* resync automerge workflow with canonical template (guidance[#15](https://github.com/vln-devsecops/actions-validate-coverage/issues/15)) ([db1453b](https://github.com/vln-devsecops/actions-validate-coverage/commit/db1453bf1df48197f9e491a8036254b40b6eebfe)), closes [#23](https://github.com/vln-devsecops/actions-validate-coverage/issues/23)

## [1.4.1](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.4.0...v1.4.1) (2026-08-04)


### Bug Fixes

* anchor last-release-sha to the actual v1.4.0 tag commit ([6db5adb](https://github.com/vln-devsecops/actions-validate-coverage/commit/6db5adb7ec6a178e8cf1ad3fd5e4a27d61c7ebe6))
* re-baseline release-please and correct duplicated changelog history ([371c7c6](https://github.com/vln-devsecops/actions-validate-coverage/commit/371c7c64bb501e294ea0acedfbc287710c0039a9))
* resync with canonical template after guidance[#12](https://github.com/vln-devsecops/actions-validate-coverage/issues/12) ([780963d](https://github.com/vln-devsecops/actions-validate-coverage/commit/780963d1b95ca4b78477eac08eb600a95d92fcb3))
* stop force-moving the exact-version release tag ([eac8ae3](https://github.com/vln-devsecops/actions-validate-coverage/commit/eac8ae3413ee94ea7461bd5290b32cc4d7d4f827))
* stop force-moving the exact-version release tag ([ce6956a](https://github.com/vln-devsecops/actions-validate-coverage/commit/ce6956a9aca43a137e596366483bbb7fd85714a5)), closes [#24](https://github.com/vln-devsecops/actions-validate-coverage/issues/24)

## [1.4.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.3.0...v1.4.0) (2026-08-02)


### Bug Fixes

* adopt canonical hardened automerge template from guidance ([da618e0](https://github.com/vln-devsecops/actions-validate-coverage/commit/da618e0723d5633bc4eb62268d10512b58d682bd)), closes [#18](https://github.com/vln-devsecops/actions-validate-coverage/issues/18)

## [1.3.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.2.0...v1.3.0) (2026-07-24)


### Bug Fixes

* **release:** publish release image tags from the release-please run ([6080194](https://github.com/vln-devsecops/actions-validate-coverage/commit/6080194569fc51caa09a404cc08d3d993f923998))

## [1.2.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.1.0...v1.2.0) (2026-07-24)


### Bug Fixes

* Fix action.yml parse error from ${{ github.token }} in input description ([fa4c379](https://github.com/vln-devsecops/actions-validate-coverage/commit/fa4c3791d0c25e379803b444947c68e46982cc7a))

## [1.1.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.0.18...v1.1.0) (2026-07-12)


### Features

* add opt-in commit-status publishing for coverage results ([4568786](https://github.com/vln-devsecops/actions-validate-coverage/commit/4568786255e2ad69231556f740ed26bd96e033b1))
* add portable JSON coverage report as an artifact-based alternative ([0452a0d](https://github.com/vln-devsecops/actions-validate-coverage/commit/0452a0d847627fc555f1e9f890eb52f4dad6a133))


### Bug Fixes

* address release-please review feedback ([7ed5bc3](https://github.com/vln-devsecops/actions-validate-coverage/commit/7ed5bc3714aebcfc6fcad5e44e0c8e527fa00b27))
* emit report-file relative to GITHUB_WORKSPACE, not a container path ([7d186c6](https://github.com/vln-devsecops/actions-validate-coverage/commit/7d186c6afc31559e39dd36611822b7118ce64f19))
* guard jq payload build so it can't abort the run under set -e ([2b867f2](https://github.com/vln-devsecops/actions-validate-coverage/commit/2b867f229ffa26dc5451851ba6f9d2aaa5b0b9bb))
