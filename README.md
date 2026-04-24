# terraform-aws-oidc-github

[![Latest Release](https://img.shields.io/github/v/release/pelotech/terraform-aws-oidc-github?sort=semver&display_name=release)](https://github.com/pelotech/terraform-aws-oidc-github/releases)

Provision GitHub Actions → AWS authentication via OpenID Connect, with no long-lived AWS keys.

This module creates the GitHub OIDC identity provider in your AWS account and one IAM role per entry in `roles`. Each role trusts a configurable set of GitHub subject claims (specific repos, branches, tags, environments, or pull requests) and attaches the IAM policies you specify. Based on the [official GitHub OIDC for AWS guide](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

## How it fits together

```
┌─────────────────────┐    OIDC token    ┌──────────────────────┐    AssumeRoleWithWebIdentity    ┌─────────────┐
│  GitHub Actions job │ ───────────────► │  AWS OIDC provider   │ ──────────────────────────────► │  IAM role   │
│  (this repo+branch) │                  │  (created by module) │                                 │ (per entry) │
└─────────────────────┘                  └──────────────────────┘                                 └─────────────┘
                                                                                                        │
                                                                                                        ▼
                                                                                                  AWS API calls
                                                                                                  (scoped by
                                                                                                   policy_arns)
```

The trust policy on each role pins the GitHub `sub` claim to the patterns in `subject_repos`, so a workflow running on the wrong repo, branch, environment, or tag cannot assume the role.

## Quickstart

```hcl
module "aws_oidc_github" {
  source  = "pelotech/oidc-github/aws"

  roles = {
    "deploy-main" = {
      subject_repos = ["repo:my-org/my-repo:ref:refs/heads/main"]
      policy_arns   = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
    }
  }
}

output "role_arn" {
  value = module.aws_oidc_github.iam_role_arns_map["deploy-main"]
}
```

`terraform apply`, copy the role ARN into your workflow (see [GitHub Actions workflow](#github-actions-workflow) below), and you're done.

## Full example

A multi-role example with comments lives in [`examples/`](./examples). Highlights:

```hcl
module "aws_oidc_github" {
  source = "pelotech/oidc-github/aws"

  roles = {
    # Production deploys: only `main`, with full access and an SSO debug escape hatch.
    "infra-prod" = {
      role_path         = "/github/"
      subject_repos     = ["repo:my-org/infrastructure:ref:refs/heads/main"]
      policy_arns       = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      assume_role_names = ["AWSReservedSSO_AdministratorAccess_xxxxxxxxxxxxxxxx"]
    }

    # PR previews: any pull request in the same repo, read-only.
    "infra-pr-preview" = {
      subject_repos = ["repo:my-org/infrastructure:pull_request"]
      policy_arns   = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }

    # Long integration job: bump the session to 4h and add a bespoke inline policy
    # for a grant that's too narrow to justify a standalone aws_iam_policy.
    "infra-integration-tests" = {
      subject_repos        = ["repo:my-org/infrastructure:environment:integration"]
      policy_arns          = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      max_session_duration = 14400 # 4h, overrides the module-level default

      inline_policies = {
        "describe-integration-stacks" = data.aws_iam_policy_document.describe_integration_stacks.json
      }
    }
  }
}
```

Each entry in `roles` supports the following keys:

- `subject_repos` (required) — OIDC subject claims allowed to assume the role. See the cheat sheet below.
- `policy_arns` (required, may be empty) — IAM policy ARNs to attach.
- `inline_policies` (optional) — Map of policy name → rendered policy document JSON. Good for one-off grants that don't deserve a standalone `aws_iam_policy`.
- `max_session_duration` (optional) — Per-role override in seconds (3600–43200). Omit to inherit the module-level `var.max_session_duration`.
- `role_path` (optional) — IAM path. Defaults to `/`.
- `assume_role_names` (optional) — IAM role names in the same account that may also `sts:AssumeRole` this role. Development-only escape hatch; see [Security notes](#security-notes).

## Subject string cheat sheet

The `subject_repos` list contains GitHub OIDC `sub` claim patterns. Common shapes:

| What you want to allow                   | Pattern                                                  |
| ---------------------------------------- | -------------------------------------------------------- |
| One specific branch                      | `repo:ORG/REPO:ref:refs/heads/main`                      |
| Any branch                               | `repo:ORG/REPO:ref:refs/heads/*`                         |
| A tag pattern (e.g. release tags)        | `repo:ORG/REPO:ref:refs/tags/v*`                         |
| A GitHub Environment (recommended)       | `repo:ORG/REPO:environment:production`                   |
| Any pull request                         | `repo:ORG/REPO:pull_request`                             |
| Any workflow in any repo of an org       | `repo:ORG/*`                                             |

GitHub's full claim reference: <https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims>.

> **Tip:** Prefer GitHub Environments over branch matching when you can — environments give you reviewer gates, secrets scoping, and protection rules on the GitHub side.

## Security notes

A few patterns that are easy to reach for and cause real damage:

- **Avoid `repo:ORG/*` on high-privilege roles.** A wildcard `sub` claim lets any repo in the org (including a private fork created by a compromised contributor) assume the role. Prefer specific repo + branch, or — better — a `repo:ORG/REPO:environment:production` claim gated by a GitHub Environment with reviewer approval.
- **Treat `assume_role_names` as a development-only escape hatch.** Never point it at a broad SSO role such as `AWSReservedSSO_AdministratorAccess_*`; that lets anyone with console access impersonate the CI role. Use a named, least-privilege debug role, and remove the entry before production.
- **Keep `max_session_duration` tight.** Start at the default (1 hour). Only raise it for workflows that demonstrably need longer sessions — AWS allows up to 12 hours, but a leaked OIDC token is valid for the full duration.

## GitHub Actions workflow

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write   # required to fetch the OIDC token
      contents: read    # required for actions/checkout
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/deploy-main
          aws-region: us-west-2
          role-duration-seconds: 3600   # max is var.max_session_duration on the role
      - run: aws sts get-caller-identity
```

The `role-to-assume` value is the full ARN of one of the roles this module created — `module.aws_oidc_github.iam_role_arns_map[<role-name>]` (the map key matches the entry name you used in `roles`).

## Debugging with `assume_role_names`

Each entry in `roles` accepts an `assume_role_names` list. Any IAM role in the same AWS account named in that list is also allowed to assume the OIDC role via plain `sts:AssumeRole` — useful while you're iterating, because you can run `aws sts assume-role --role-arn ...` from your laptop and act as the workflow.

> Remove `assume_role_names` (or set it to `[]`) before going to production. Once the workflow is stable, the only path to the role should be the OIDC trust.

## Troubleshooting

**`Not authorized to perform sts:AssumeRoleWithWebIdentity`**
Almost always a `sub` claim mismatch. Add `--debug` to `aws-actions/configure-aws-credentials` (or look at the OIDC step output) to see the exact `sub` GitHub sent, then compare it character-for-character to your `subject_repos` patterns. Watch out for branch vs. tag vs. environment vs. pull_request differences.

**`MalformedPolicyDocument: Invalid principal in policy`**
Usually means the OIDC provider hasn't finished creating yet, or the ARN passed into the role's trust policy is wrong. Re-run `terraform apply`.

**`role_path` rejected**
IAM paths must start and end with `/` (e.g. `"/"`, `"/github/"`, `"/teams/platform/"`).

**Wrong AWS account**
The role lives in the account where you applied this module. The `role-to-assume` ARN in the workflow must reference *that* account ID.

**Custom audience**
If you set `audience:` on `aws-actions/configure-aws-credentials`, set the matching `aud_value` here. The default (`sts.amazonaws.com`) matches the action's default.

## Contributing & releases

- This repo uses [Conventional Commits](https://www.conventionalcommits.org/) and `release-please` to drive versioning. Use `feat:`, `fix:`, `chore:`, etc. so the changelog and version bumps are correct.
- `pre-commit run --all-files` should pass before pushing — it runs `terraform fmt`, `terraform_tflint`, `yamllint`, and friends.
- Licensed under [MIT](./LICENSE).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.39.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.39.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aws_oidc_github"></a> [aws\_oidc\_github](#module\_aws\_oidc\_github) | ./modules/aws-roles-oidc-github | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aud_value"></a> [aud\_value](#input\_aud\_value) | Audience claim required in the OIDC token. Defaults to the value the official aws-actions/configure-aws-credentials action sends. | `string` | `"sts.amazonaws.com"` | no |
| <a name="input_github_tls_url"></a> [github\_tls\_url](#input\_github\_tls\_url) | GitHub OIDC issuer URL. Override only for GitHub Enterprise Server. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration in seconds for every role created. Defaults to 1 hour. Increase up to 43200 (12h) if your workflows need longer sessions. | `number` | `3600` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Map of IAM roles to create. The map key is the role name. Each value defines:<br/>  - `subject_repos`        : OIDC subject claims allowed to assume this role (e.g. "repo:my-org/my-repo:ref:refs/heads/main").<br/>  - `policy_arns`          : IAM policy ARNs to attach to the role.<br/>  - `role_path`            : (optional) IAM path for the role. Defaults to "/".<br/>  - `assume_role_names`    : (optional) IAM role names in the same account that may also assume this role (useful for local debugging).<br/>  - `max_session_duration` : (optional) Per-role override of the module-level max\_session\_duration, in seconds. Must be 3600-43200. Omit to inherit var.max\_session\_duration.<br/>  - `inline_policies`      : (optional) Map of inline IAM policy name to rendered policy document JSON (typically from data.aws\_iam\_policy\_document.<name>.json). | <pre>map(object({<br/>    role_path            = optional(string, "/")<br/>    subject_repos        = list(string)<br/>    policy_arns          = list(string)<br/>    assume_role_names    = optional(list(string))<br/>    max_session_duration = optional(number)<br/>    inline_policies      = optional(map(string), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the OIDC provider and every IAM role created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#output\_github\_oidc\_provider\_arn) | oidc provider arn to use for roles/policies |
| <a name="output_github_oidc_provider_url"></a> [github\_oidc\_provider\_url](#output\_github\_oidc\_provider\_url) | oidc provider url to use for roles/policies |
| <a name="output_iam_role_arns_map"></a> [iam\_role\_arns\_map](#output\_iam\_role\_arns\_map) | Map of role name to IAM role ARN. |
| <a name="output_iam_role_names"></a> [iam\_role\_names](#output\_iam\_role\_names) | Map of role name (the var.roles key) to the created IAM role name. Useful for wiring downstream resources (e.g. aws\_iam\_role\_policy) without parsing the ARN. |
<!-- END_TF_DOCS -->
