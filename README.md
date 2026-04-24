# terraform-aws-oidc-github

Provision GitHub Actions → AWS authentication via OpenID Connect, with no long-lived AWS keys.

This module creates the GitHub OIDC identity provider in your AWS account and one IAM role per entry in `role_subject-repos_policies`. Each role trusts a configurable set of GitHub subject claims (specific repos, branches, tags, environments, or pull requests) and attaches the IAM policies you specify. Based on the [official GitHub OIDC for AWS guide](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

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

  role_subject-repos_policies = {
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

  role_subject-repos_policies = {
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
  }
}
```

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

The `role-to-assume` value is the full ARN of one of the roles this module created — `module.aws_oidc_github.iam_role_arns_map[<role-name>]` (the map key matches the entry name you used in `role_subject-repos_policies`). The older `iam_role_arns` flat-list output is deprecated and will be removed in v2.

## Debugging with `assume_role_names`

Each entry in `role_subject-repos_policies` accepts an `assume_role_names` list. Any IAM role in the same AWS account named in that list is also allowed to assume the OIDC role via plain `sts:AssumeRole` — useful while you're iterating, because you can run `aws sts assume-role --role-arn ...` from your laptop and act as the workflow.

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

## Wrappers

The [`wrappers/`](./wrappers) directory contains thin wrapper modules pre-configured to call this module. They're useful if you'd rather declare your roles in `terraform.tfvars`-friendly shapes than write a `module` block. Most users won't need them.

## Contributing & releases

- This repo uses [Conventional Commits](https://www.conventionalcommits.org/) and `release-please` to drive versioning. Use `feat:`, `fix:`, `chore:`, etc. so the changelog and version bumps are correct.
- `pre-commit run --all-files` should pass before pushing — it runs `terraform fmt`, `terraform_tflint`, `yamllint`, and friends.
- Licensed under [MIT](./LICENSE).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

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
| <a name="input_role_subject-repos_policies"></a> [role\_subject-repos\_policies](#input\_role\_subject-repos\_policies) | Map of IAM roles to create. The map key is the role name. Each value defines:<br/>  - `subject_repos`     : OIDC subject claims allowed to assume this role (e.g. "repo:my-org/my-repo:ref:refs/heads/main").<br/>  - `policy_arns`       : IAM policy ARNs to attach to the role.<br/>  - `role_path`         : (optional) IAM path for the role. Defaults to "/".<br/>  - `assume_role_names` : (optional) IAM role names in the same account that may also assume this role (useful for local debugging). | <pre>map(object({<br/>    role_path         = optional(string, "/")<br/>    subject_repos     = list(string)<br/>    policy_arns       = list(string)<br/>    assume_role_names = optional(list(string))<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the OIDC provider and every IAM role created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#output\_github\_oidc\_provider\_arn) | oidc provider arn to use for roles/policies |
| <a name="output_github_oidc_provider_url"></a> [github\_oidc\_provider\_url](#output\_github\_oidc\_provider\_url) | oidc provider url to use for roles/policies |
| <a name="output_iam_role_arns"></a> [iam\_role\_arns](#output\_iam\_role\_arns) | Roles that will be assumed by GitHub Action. (Deprecated: use `iam_role_arns_map` instead; this output will be removed in v2.) |
| <a name="output_iam_role_arns_map"></a> [iam\_role\_arns\_map](#output\_iam\_role\_arns\_map) | Map of role name to role ARN. Prefer this output; the flat `iam_role_arns` list will be removed in v2. |
<!-- END_TF_DOCS -->
