# Changelog

## [1.4.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.3.0...v1.4.0) (2026-08-02)


### Features

* Add automated dependabot handling with patch releases ([49f8e66](https://github.com/vln-devsecops/actions-validate-coverage/commit/49f8e66774b921bec4554d0194069dc6b3dc5e0b))
* add Docker image testing and validation workflows ([25d027a](https://github.com/vln-devsecops/actions-validate-coverage/commit/25d027ab4c9b1d722278f9099dfe885f6f4fd7b5))
* add opt-in commit-status publishing for coverage results ([4568786](https://github.com/vln-devsecops/actions-validate-coverage/commit/4568786255e2ad69231556f740ed26bd96e033b1))
* add portable JSON coverage report as an artifact-based alternative ([0452a0d](https://github.com/vln-devsecops/actions-validate-coverage/commit/0452a0d847627fc555f1e9f890eb52f4dad6a133))
* Add validation workflow for action.yml and enforce versioning strategy ([6f90f27](https://github.com/vln-devsecops/actions-validate-coverage/commit/6f90f27148b72a495c32289369931084452735bc))
* Implement automated release process with versioning and action updates ([36ea713](https://github.com/vln-devsecops/actions-validate-coverage/commit/36ea71345ab9c4d0a95c0c80e127be7063f6b47e))
* Refactor workflows for streamlined release process and improved version management ([c0f4daf](https://github.com/vln-devsecops/actions-validate-coverage/commit/c0f4daf5445e4145b7a316add895ad96c0ca611b))
* Simplify to manual-only releases with intelligent version selection ([7f1f190](https://github.com/vln-devsecops/actions-validate-coverage/commit/7f1f1907baa0408685b92ea9fb21171aa5b6e16f))
* Update dependabot configuration and add autoversion workflow ([9ba13a8](https://github.com/vln-devsecops/actions-validate-coverage/commit/9ba13a82cc403c5f7f6a5c29a1bb3b652f79b64d))


### Bug Fixes

* **action:** update image format for Docker in validate coverage action ([9dd9c47](https://github.com/vln-devsecops/actions-validate-coverage/commit/9dd9c4714d27422e00f35638507d97a7e07b5504))
* Add permissions and fix test dependencies in autoversion workflow ([46b7c36](https://github.com/vln-devsecops/actions-validate-coverage/commit/46b7c36b2137fb225a0d35ced8233cc3586dac47))
* address release-please review feedback ([7ed5bc3](https://github.com/vln-devsecops/actions-validate-coverage/commit/7ed5bc3714aebcfc6fcad5e44e0c8e527fa00b27))
* adopt canonical hardened automerge template from guidance ([da618e0](https://github.com/vln-devsecops/actions-validate-coverage/commit/da618e0723d5633bc4eb62268d10512b58d682bd)), closes [#18](https://github.com/vln-devsecops/actions-validate-coverage/issues/18)
* **create-release.sh:** update image reference format in action.yml to use docker protocol ([b363335](https://github.com/vln-devsecops/actions-validate-coverage/commit/b363335264d4f67bb6f83609f3a2b3694af43a1f))
* emit report-file relative to GITHUB_WORKSPACE, not a container path ([7d186c6](https://github.com/vln-devsecops/actions-validate-coverage/commit/7d186c6afc31559e39dd36611822b7118ce64f19))
* guard jq payload build so it can't abort the run under set -e ([2b867f2](https://github.com/vln-devsecops/actions-validate-coverage/commit/2b867f229ffa26dc5451851ba6f9d2aaa5b0b9bb))
* Improve ANSI color formatting in interactive version display ([ad2e743](https://github.com/vln-devsecops/actions-validate-coverage/commit/ad2e743ffbe1b3748733164f7428f1413d867233))
* Improve interactive version selection display in release script ([0025ac3](https://github.com/vln-devsecops/actions-validate-coverage/commit/0025ac371b574878ea846587e64eabb4e88144c3))
* opt workflows into node24 actions runtime ([350a915](https://github.com/vln-devsecops/actions-validate-coverage/commit/350a915dfc3fabc7d8a661cf95ba018a687e8e9b))
* **release:** publish release image tags from the release-please run ([6080194](https://github.com/vln-devsecops/actions-validate-coverage/commit/6080194569fc51caa09a404cc08d3d993f923998))
* Remove problematic workflow call step ([f2e6176](https://github.com/vln-devsecops/actions-validate-coverage/commit/f2e617616c5a6559e7fa37b7bb8775d87780f02a))
* remove v prefix from GHCR image tags in release scripts ([a446f66](https://github.com/vln-devsecops/actions-validate-coverage/commit/a446f6661b6276bf2521c6be9ea43a916447b270))
* Update autoversion workflow conditions ([d52b64c](https://github.com/vln-devsecops/actions-validate-coverage/commit/d52b64cc7bb8b5eda56adc6f6678710ff1dba5a7))
* Update Docker image tag to use 'latest' for validate-coverage action ([f91eb98](https://github.com/vln-devsecops/actions-validate-coverage/commit/f91eb98cdc8ed306816d6e8d94bf208e4cde9fdc))
* **workflows:** update permissions to write for release branch workflows ([84664eb](https://github.com/vln-devsecops/actions-validate-coverage/commit/84664eb84a1247a467f6a03ca9a5401c74988a4a))

## [1.3.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.2.0...v1.3.0) (2026-07-24)


### Features

* Add automated dependabot handling with patch releases ([49f8e66](https://github.com/vln-devsecops/actions-validate-coverage/commit/49f8e66774b921bec4554d0194069dc6b3dc5e0b))
* add Docker image testing and validation workflows ([25d027a](https://github.com/vln-devsecops/actions-validate-coverage/commit/25d027ab4c9b1d722278f9099dfe885f6f4fd7b5))
* add opt-in commit-status publishing for coverage results ([4568786](https://github.com/vln-devsecops/actions-validate-coverage/commit/4568786255e2ad69231556f740ed26bd96e033b1))
* add portable JSON coverage report as an artifact-based alternative ([0452a0d](https://github.com/vln-devsecops/actions-validate-coverage/commit/0452a0d847627fc555f1e9f890eb52f4dad6a133))
* Add validation workflow for action.yml and enforce versioning strategy ([6f90f27](https://github.com/vln-devsecops/actions-validate-coverage/commit/6f90f27148b72a495c32289369931084452735bc))
* Implement automated release process with versioning and action updates ([36ea713](https://github.com/vln-devsecops/actions-validate-coverage/commit/36ea71345ab9c4d0a95c0c80e127be7063f6b47e))
* Refactor workflows for streamlined release process and improved version management ([c0f4daf](https://github.com/vln-devsecops/actions-validate-coverage/commit/c0f4daf5445e4145b7a316add895ad96c0ca611b))
* Simplify to manual-only releases with intelligent version selection ([7f1f190](https://github.com/vln-devsecops/actions-validate-coverage/commit/7f1f1907baa0408685b92ea9fb21171aa5b6e16f))
* Update dependabot configuration and add autoversion workflow ([9ba13a8](https://github.com/vln-devsecops/actions-validate-coverage/commit/9ba13a82cc403c5f7f6a5c29a1bb3b652f79b64d))


### Bug Fixes

* **action:** update image format for Docker in validate coverage action ([9dd9c47](https://github.com/vln-devsecops/actions-validate-coverage/commit/9dd9c4714d27422e00f35638507d97a7e07b5504))
* Add permissions and fix test dependencies in autoversion workflow ([46b7c36](https://github.com/vln-devsecops/actions-validate-coverage/commit/46b7c36b2137fb225a0d35ced8233cc3586dac47))
* address release-please review feedback ([7ed5bc3](https://github.com/vln-devsecops/actions-validate-coverage/commit/7ed5bc3714aebcfc6fcad5e44e0c8e527fa00b27))
* **create-release.sh:** update image reference format in action.yml to use docker protocol ([b363335](https://github.com/vln-devsecops/actions-validate-coverage/commit/b363335264d4f67bb6f83609f3a2b3694af43a1f))
* emit report-file relative to GITHUB_WORKSPACE, not a container path ([7d186c6](https://github.com/vln-devsecops/actions-validate-coverage/commit/7d186c6afc31559e39dd36611822b7118ce64f19))
* guard jq payload build so it can't abort the run under set -e ([2b867f2](https://github.com/vln-devsecops/actions-validate-coverage/commit/2b867f229ffa26dc5451851ba6f9d2aaa5b0b9bb))
* Improve ANSI color formatting in interactive version display ([ad2e743](https://github.com/vln-devsecops/actions-validate-coverage/commit/ad2e743ffbe1b3748733164f7428f1413d867233))
* Improve interactive version selection display in release script ([0025ac3](https://github.com/vln-devsecops/actions-validate-coverage/commit/0025ac371b574878ea846587e64eabb4e88144c3))
* opt workflows into node24 actions runtime ([350a915](https://github.com/vln-devsecops/actions-validate-coverage/commit/350a915dfc3fabc7d8a661cf95ba018a687e8e9b))
* **release:** publish release image tags from the release-please run ([6080194](https://github.com/vln-devsecops/actions-validate-coverage/commit/6080194569fc51caa09a404cc08d3d993f923998))
* Remove problematic workflow call step ([f2e6176](https://github.com/vln-devsecops/actions-validate-coverage/commit/f2e617616c5a6559e7fa37b7bb8775d87780f02a))
* remove v prefix from GHCR image tags in release scripts ([a446f66](https://github.com/vln-devsecops/actions-validate-coverage/commit/a446f6661b6276bf2521c6be9ea43a916447b270))
* Update autoversion workflow conditions ([d52b64c](https://github.com/vln-devsecops/actions-validate-coverage/commit/d52b64cc7bb8b5eda56adc6f6678710ff1dba5a7))
* Update Docker image tag to use 'latest' for validate-coverage action ([f91eb98](https://github.com/vln-devsecops/actions-validate-coverage/commit/f91eb98cdc8ed306816d6e8d94bf208e4cde9fdc))
* **workflows:** update permissions to write for release branch workflows ([84664eb](https://github.com/vln-devsecops/actions-validate-coverage/commit/84664eb84a1247a467f6a03ca9a5401c74988a4a))

## [1.2.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.1.0...v1.2.0) (2026-07-24)


### Features

* Add automated dependabot handling with patch releases ([49f8e66](https://github.com/vln-devsecops/actions-validate-coverage/commit/49f8e66774b921bec4554d0194069dc6b3dc5e0b))
* add Docker image testing and validation workflows ([25d027a](https://github.com/vln-devsecops/actions-validate-coverage/commit/25d027ab4c9b1d722278f9099dfe885f6f4fd7b5))
* add opt-in commit-status publishing for coverage results ([4568786](https://github.com/vln-devsecops/actions-validate-coverage/commit/4568786255e2ad69231556f740ed26bd96e033b1))
* add portable JSON coverage report as an artifact-based alternative ([0452a0d](https://github.com/vln-devsecops/actions-validate-coverage/commit/0452a0d847627fc555f1e9f890eb52f4dad6a133))
* Add validation workflow for action.yml and enforce versioning strategy ([6f90f27](https://github.com/vln-devsecops/actions-validate-coverage/commit/6f90f27148b72a495c32289369931084452735bc))
* Implement automated release process with versioning and action updates ([36ea713](https://github.com/vln-devsecops/actions-validate-coverage/commit/36ea71345ab9c4d0a95c0c80e127be7063f6b47e))
* Refactor workflows for streamlined release process and improved version management ([c0f4daf](https://github.com/vln-devsecops/actions-validate-coverage/commit/c0f4daf5445e4145b7a316add895ad96c0ca611b))
* Simplify to manual-only releases with intelligent version selection ([7f1f190](https://github.com/vln-devsecops/actions-validate-coverage/commit/7f1f1907baa0408685b92ea9fb21171aa5b6e16f))
* Update dependabot configuration and add autoversion workflow ([9ba13a8](https://github.com/vln-devsecops/actions-validate-coverage/commit/9ba13a82cc403c5f7f6a5c29a1bb3b652f79b64d))


### Bug Fixes

* **action:** update image format for Docker in validate coverage action ([9dd9c47](https://github.com/vln-devsecops/actions-validate-coverage/commit/9dd9c4714d27422e00f35638507d97a7e07b5504))
* Add permissions and fix test dependencies in autoversion workflow ([46b7c36](https://github.com/vln-devsecops/actions-validate-coverage/commit/46b7c36b2137fb225a0d35ced8233cc3586dac47))
* address release-please review feedback ([7ed5bc3](https://github.com/vln-devsecops/actions-validate-coverage/commit/7ed5bc3714aebcfc6fcad5e44e0c8e527fa00b27))
* **create-release.sh:** update image reference format in action.yml to use docker protocol ([b363335](https://github.com/vln-devsecops/actions-validate-coverage/commit/b363335264d4f67bb6f83609f3a2b3694af43a1f))
* emit report-file relative to GITHUB_WORKSPACE, not a container path ([7d186c6](https://github.com/vln-devsecops/actions-validate-coverage/commit/7d186c6afc31559e39dd36611822b7118ce64f19))
* guard jq payload build so it can't abort the run under set -e ([2b867f2](https://github.com/vln-devsecops/actions-validate-coverage/commit/2b867f229ffa26dc5451851ba6f9d2aaa5b0b9bb))
* Improve ANSI color formatting in interactive version display ([ad2e743](https://github.com/vln-devsecops/actions-validate-coverage/commit/ad2e743ffbe1b3748733164f7428f1413d867233))
* Improve interactive version selection display in release script ([0025ac3](https://github.com/vln-devsecops/actions-validate-coverage/commit/0025ac371b574878ea846587e64eabb4e88144c3))
* opt workflows into node24 actions runtime ([350a915](https://github.com/vln-devsecops/actions-validate-coverage/commit/350a915dfc3fabc7d8a661cf95ba018a687e8e9b))
* Remove problematic workflow call step ([f2e6176](https://github.com/vln-devsecops/actions-validate-coverage/commit/f2e617616c5a6559e7fa37b7bb8775d87780f02a))
* remove v prefix from GHCR image tags in release scripts ([a446f66](https://github.com/vln-devsecops/actions-validate-coverage/commit/a446f6661b6276bf2521c6be9ea43a916447b270))
* Update autoversion workflow conditions ([d52b64c](https://github.com/vln-devsecops/actions-validate-coverage/commit/d52b64cc7bb8b5eda56adc6f6678710ff1dba5a7))
* Update Docker image tag to use 'latest' for validate-coverage action ([f91eb98](https://github.com/vln-devsecops/actions-validate-coverage/commit/f91eb98cdc8ed306816d6e8d94bf208e4cde9fdc))
* **workflows:** update permissions to write for release branch workflows ([84664eb](https://github.com/vln-devsecops/actions-validate-coverage/commit/84664eb84a1247a467f6a03ca9a5401c74988a4a))

## [1.1.0](https://github.com/vln-devsecops/actions-validate-coverage/compare/v1.0.18...v1.1.0) (2026-07-12)


### Features

* add opt-in commit-status publishing for coverage results ([4568786](https://github.com/vln-devsecops/actions-validate-coverage/commit/4568786255e2ad69231556f740ed26bd96e033b1))
* add portable JSON coverage report as an artifact-based alternative ([0452a0d](https://github.com/vln-devsecops/actions-validate-coverage/commit/0452a0d847627fc555f1e9f890eb52f4dad6a133))


### Bug Fixes

* address release-please review feedback ([7ed5bc3](https://github.com/vln-devsecops/actions-validate-coverage/commit/7ed5bc3714aebcfc6fcad5e44e0c8e527fa00b27))
* emit report-file relative to GITHUB_WORKSPACE, not a container path ([7d186c6](https://github.com/vln-devsecops/actions-validate-coverage/commit/7d186c6afc31559e39dd36611822b7118ce64f19))
* guard jq payload build so it can't abort the run under set -e ([2b867f2](https://github.com/vln-devsecops/actions-validate-coverage/commit/2b867f229ffa26dc5451851ba6f9d2aaa5b0b9bb))
