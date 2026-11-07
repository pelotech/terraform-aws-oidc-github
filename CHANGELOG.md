# Changelog

## [1.2.1](https://github.com/pelotech/terraform-aws-oidc-github/compare/v1.2.0...v1.2.1) (2026-11-07)


### Bug Fixes

* render a single sts:AssumeRole statement for assume_role_names ([#36](https://github.com/pelotech/terraform-aws-oidc-github/issues/36)) ([18d3d8a](https://github.com/pelotech/terraform-aws-oidc-github/commit/18d3d8a118fd9c47aa199331effefe20b5608b06))


### Chores

* change code owners to foundation ([1ed489c](https://github.com/pelotech/terraform-aws-oidc-github/commit/1ed489cac3b287b6d771e7ffd5248e6b65d59a81))
* **config:** migrate Renovate config ([#29](https://github.com/pelotech/terraform-aws-oidc-github/issues/29)) ([ac35017](https://github.com/pelotech/terraform-aws-oidc-github/commit/ac35017efe914cd2c95b749d61836bf2a660cf9b))
* **deps:** update actions/checkout action to v7 ([#23](https://github.com/pelotech/terraform-aws-oidc-github/issues/23)) ([aa043cb](https://github.com/pelotech/terraform-aws-oidc-github/commit/aa043cbc38b5c3c10ccf9f03fa1941eeae9f4ab8))
* **deps:** update cachix/install-nix-action digest to 75c75c3 ([#34](https://github.com/pelotech/terraform-aws-oidc-github/issues/34)) ([38b81ae](https://github.com/pelotech/terraform-aws-oidc-github/commit/38b81aee70f171d963fa421547f65899eaea9d5f))
* **deps:** update hashicorp/setup-terraform digest to dfe3c3f ([#21](https://github.com/pelotech/terraform-aws-oidc-github/issues/21)) ([4938317](https://github.com/pelotech/terraform-aws-oidc-github/commit/4938317610860f758141342cea55f651afa07902))
* **deps:** update lint tooling ([#38](https://github.com/pelotech/terraform-aws-oidc-github/issues/38)) ([0249d10](https://github.com/pelotech/terraform-aws-oidc-github/commit/0249d10d4c589980ff3e57d569575f29181e4ed9))
* **deps:** update pre-commit hook pre-commit/pre-commit-hooks to v6 ([#39](https://github.com/pelotech/terraform-aws-oidc-github/issues/39)) ([3c09f93](https://github.com/pelotech/terraform-aws-oidc-github/commit/3c09f93c1406b827d19f743aa9e9877917c3337f))
* **deps:** update tflint plugin terraform-linters/tflint-ruleset-aws to v0.48.0 ([#24](https://github.com/pelotech/terraform-aws-oidc-github/issues/24)) ([0a14104](https://github.com/pelotech/terraform-aws-oidc-github/commit/0a14104b54a785ccb2676e21cafc7962c59e350c))
* remove pre-commit module creation ([8fb07db](https://github.com/pelotech/terraform-aws-oidc-github/commit/8fb07db07ec731a81abac511f665cb50096d2960))
* **renovate:** group pre-commit and tflint plugin updates into one PR ([#37](https://github.com/pelotech/terraform-aws-oidc-github/issues/37)) ([5cc0838](https://github.com/pelotech/terraform-aws-oidc-github/commit/5cc08389348219ca5b6607d8df91f96d405a700d))
* update to nix and add action linting ([#26](https://github.com/pelotech/terraform-aws-oidc-github/issues/26)) ([f7615fc](https://github.com/pelotech/terraform-aws-oidc-github/commit/f7615fcef6068a367cc94a392f95f0b8bb114cec))

## [1.2.0](https://github.com/pelotech/terraform-aws-oidc-github/compare/v1.1.0...v1.2.0) (2026-04-24)


### Features

* per-role max_session_duration and inline policy support ([#18](https://github.com/pelotech/terraform-aws-oidc-github/issues/18)) ([afd2289](https://github.com/pelotech/terraform-aws-oidc-github/commit/afd228952b6c9bdb31bbb2932e202b0a0216cf5f))

## [1.1.0](https://github.com/pelotech/terraform-aws-oidc-github/compare/v1.0.0...v1.1.0) (2026-04-24)


### Features

* v1.1 validations and iam_role_names output ([#17](https://github.com/pelotech/terraform-aws-oidc-github/issues/17)) ([1dc106f](https://github.com/pelotech/terraform-aws-oidc-github/commit/1dc106f5641fb12ba757a4216fc57f018df71031))


### Docs

* remove wrappers/ reference from README ([#14](https://github.com/pelotech/terraform-aws-oidc-github/issues/14)) ([55141bc](https://github.com/pelotech/terraform-aws-oidc-github/commit/55141bcd4edc969c149afa838214b44b3555a00d))
* security notes + repo hygiene (badge, CODEOWNERS, issue template) ([#16](https://github.com/pelotech/terraform-aws-oidc-github/issues/16)) ([fa474f1](https://github.com/pelotech/terraform-aws-oidc-github/commit/fa474f120647b556aef9a8ed1c0dfee2977a883c))

## [1.0.0](https://github.com/pelotech/terraform-aws-oidc-github/compare/v0.6.0...v1.0.0) (2026-04-24)


### ⚠ BREAKING CHANGES

* v2 cleanup — rename input, drop deprecated internals, modernize provider ([#12](https://github.com/pelotech/terraform-aws-oidc-github/issues/12))

### Features

* v2 cleanup — rename input, drop deprecated internals, modernize provider ([#12](https://github.com/pelotech/terraform-aws-oidc-github/issues/12)) ([3d791e2](https://github.com/pelotech/terraform-aws-oidc-github/commit/3d791e2aa55cf685b94b274520802892b97d2446))

## [0.6.0](https://github.com/pelotech/terraform-aws-oidc-github/compare/v0.5.0...v0.6.0) (2026-04-24)


### Features

* add tags, iam_role_arns_map, and variable validation (Stage 1 prep for v2) ([#11](https://github.com/pelotech/terraform-aws-oidc-github/issues/11)) ([5bb42c6](https://github.com/pelotech/terraform-aws-oidc-github/commit/5bb42c6edace764515b2dca6319bb1d9913511af))


### Docs

* overhaul README, fix broken example, tighten variable descriptions ([#9](https://github.com/pelotech/terraform-aws-oidc-github/issues/9)) ([367b57b](https://github.com/pelotech/terraform-aws-oidc-github/commit/367b57b2a1a4870b6e96537222a0300c30053534))

## [0.5.0](https://github.com/pelotech/terraform-aws-oidc-github/compare/v0.4.2...v0.5.0) (2026-04-23)


### Features

* add pre-commit, release-please, renovate, and other standard tooling for lint and keeping dependencies up to date ([f4401cf](https://github.com/pelotech/terraform-aws-oidc-github/commit/f4401cfc955a3aa43c341635c7284a2c4c2d00b5))


### Bug Fixes

* allows versions above 4.x for the aws provider ([837360a](https://github.com/pelotech/terraform-aws-oidc-github/commit/837360adc7f2d05ced1a48799cb312e9f68e6dfd))


### Chores

* **deps:** update googleapis/release-please-action action to v5 ([3169513](https://github.com/pelotech/terraform-aws-oidc-github/commit/3169513ac5bb314f41acc0f41b4779a3d8e033b9))
* enable sematicCommits for renovate ([d2a033d](https://github.com/pelotech/terraform-aws-oidc-github/commit/d2a033d34bf803f7120c4c2a3644f3a881b3892f))
