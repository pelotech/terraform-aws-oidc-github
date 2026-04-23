# Example: GitHub Actions OIDC roles in AWS

This example provisions:

- A GitHub OIDC identity provider in your AWS account.
- Two IAM roles trusted by that provider:
  - `org-infra-main` — full Administrator access, only assumable from the `main` branch of `organization/infrastructure`. Also assumable by an SSO role for local debugging.
  - `org-infra-all-branches` — `AmazonS3ReadOnlyAccess`, assumable from any branch of the same repo.

## Prerequisites

- Terraform `>= 1.5.7`
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
