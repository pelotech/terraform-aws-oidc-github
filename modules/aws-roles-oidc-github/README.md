# aws-roles-oidc-github (internal submodule)

This is an **internal building block** consumed by the root [`terraform-aws-oidc-github`](../../README.md) module. Most users should consume the root module directly — it provisions the OIDC provider and calls this submodule once per role you define in `role_subject-repos_policies`.

Use this submodule directly **only** if you already manage your `aws_iam_openid_connect_provider` elsewhere and want to layer additional roles onto it without re-creating the provider. In that case, pass the existing provider's ARN and URL into `github_oidc_provider_arn` and `github_oidc_provider_url`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.github_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_names"></a> [assume\_role\_names](#input\_assume\_role\_names) | IAM role names in the same account that may assume this role via sts:AssumeRole. Useful for local debugging; remove before production. | `list(string)` | `[]` | no |
| <a name="input_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#input\_github\_oidc\_provider\_arn) | ARN of the GitHub OIDC provider that the IAM role will trust. | `string` | n/a | yes |
| <a name="input_github_oidc_provider_url"></a> [github\_oidc\_provider\_url](#input\_github\_oidc\_provider\_url) | URL of the GitHub OIDC provider (e.g. https://token.actions.githubusercontent.com). | `string` | n/a | yes |
| <a name="input_github_repos"></a> [github\_repos](#input\_github\_repos) | Subject claims (repo:org/repo:ref:refs/heads/main, repo:org/repo:environment:prod, etc.) the role will allow to assume it. | `list(string)` | n/a | yes |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration in seconds for the role. Defaults to 1 hour. Increase up to 43200 (12h) if your workflows need longer sessions. | `number` | `3600` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | IAM policy ARNs to attach to the role (managed or customer-managed policies). | `list(string)` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role to create. Used verbatim — no prefixing or sanitization is applied. | `string` | n/a | yes |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | IAM path to create the role under. Must start and end with '/' (e.g. '/' or '/github/'). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | Role that will be assumed by GitHub Action |
<!-- END_TF_DOCS -->
