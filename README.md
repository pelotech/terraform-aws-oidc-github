# oidc-aws-github
Terraform module to configure GitHub Actions with AWS Identity Provider Open ID Connect (ODIC.) This allows Github Actions to authenticate against AWS without using any long lived keys. This module provisions the necessary role and permissions as defined in the [official GitHub docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

## Debugging features
The `assume_role_names` input allows you to assume the OIDC role and act as if you were the GitHub Actions pipeline. This is very useful for debugging while you're getting things setup. Note: we recommend removing this once you're production ready so that all further changes are only applied via the pipeline.

## Example GitHub Action
```yaml
jobs:
  apply-terraform-main:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v2
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: arn:aws:iam::{account_id}:role/ci/GithubCI-OIDC-TF
          aws-region: us-west-2
          role-duration-seconds: 1200 #can be up to the max set in the terraform module, defaults to 15 min
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.github_ci](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [tls_certificate.github](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_names"></a> [assume\_role\_names](#input\_assume\_role\_names) | List of roles that can assume the OIDC role. Useful for debuging cluster before aws-config is updated. | `list(string)` | `null` | no |
| <a name="input_github_repos"></a> [github\_repos](#input\_github\_repos) | A list of repositories the OIDC role should have access to. | `list(any)` | n/a | yes |
| <a name="input_github_url"></a> [github\_url](#input\_github\_url) | Github URL to perform TLS verification against. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_managed_policy_names"></a> [managed\_policy\_names](#input\_managed\_policy\_names) | Managed policy names to attach to the OIDC role. | `list(any)` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the OIDC role. Note: this will be prefixed with 'GithubCI-OIDC-' | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ROLE_ARN"></a> [ROLE\_ARN](#output\_ROLE\_ARN) | Role that will be assumed by GitHub actions |
<!-- END_TF_DOCS -->
