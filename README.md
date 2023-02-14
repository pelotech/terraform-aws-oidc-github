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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_oidc_github"></a> [aws\_oidc\_github](#module\_aws\_oidc\_github) | ./modules/aws-oidc-github | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_names"></a> [assume\_role\_names](#input\_assume\_role\_names) | List of roles that can assume the OIDC role. Useful for debugging cluster before aws-config is updated. | `list(string)` | `[]` | no |
| <a name="input_aud_value"></a> [aud\_value](#input\_aud\_value) | GitHub Aud | `string` | `"sts.amazonaws.com"` | no |
| <a name="input_github_tls_url"></a> [github\_tls\_url](#input\_github\_tls\_url) | GitHub URL to perform TLS verification against. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_match_field"></a> [match\_field](#input\_match\_field) | GitHub match\_field. | `string` | `"sub"` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration in seconds. - by default assume role will be 15 minutes - when calling from actions you'll need to increase up to the maximum allowed hwere | `number` | `3600` | no |
| <a name="input_subject_roles"></a> [subject\_roles](#input\_subject\_roles) | Subject to role mapping. Ex: repo:organization/infrastructure:ref:refs/heads/main -> [AdministratorAccess, AmazonS3FullAccess, CustomUserPolicyOne] | `map(list(string))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | Role that will be assumed by GitHub Action |
<!-- END_TF_DOCS -->