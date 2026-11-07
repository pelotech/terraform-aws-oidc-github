# Example: GitHub Actions OIDC roles in AWS

This example provisions:

- A GitHub OIDC identity provider in your AWS account.
- Two IAM roles trusted by that provider:
  - `org-infra-main` — full Administrator access, only assumable from the `main` branch of `organization/infrastructure`. Also assumable by an SSO role for local debugging.
  - `org-infra-all-branches` — `AmazonS3ReadOnlyAccess`, assumable from any branch of the same repo.

## Prerequisites

- Terraform `>= 1.7.0`
- AWS credentials with permission to manage IAM and OIDC providers (e.g. via `aws-sso-cli` or `AWS_PROFILE`)
- Update `provider "aws"` in `main.tf` with the region you want the roles created in.
- Replace `organization/infrastructure` with your own `org/repo` and the placeholder SSO role with one from your account.

## Run it

```sh
terraform init
terraform plan
terraform apply
```

## Clean up

```sh
terraform destroy
```

## Next steps

See the [root README](../README.md) for the full input reference, the GitHub Actions workflow snippet, the subject-string cheat sheet, and troubleshooting.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.39.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aws_oidc_github"></a> [aws\_oidc\_github](#module\_aws\_oidc\_github) | pelotech/oidc-github/aws | ~> 1.2 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#output\_github\_oidc\_provider\_arn) | ARN of the GitHub OIDC provider created by the example. |
| <a name="output_iam_role_arns_map"></a> [iam\_role\_arns\_map](#output\_iam\_role\_arns\_map) | Map of role name to IAM role ARN. Use these as `role-to-assume` in your workflows. |
<!-- END_TF_DOCS -->
