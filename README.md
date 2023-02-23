# oidc-aws-github
Terraform module to configure GitHub Actions with AWS Identity Provider Open ID Connect (ODIC.)
This allows GitHub Actions to authenticate against AWS without using any long-lived keys.
This module provisions the necessary role and permissions as defined in the
[official GitHub docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

## Multiple repo configuration
This module allows you to create roles for lists of repos(subjects) and policies in the AWS account.
Curently it only supports policies in the same account as the role being created.
This is helpful for non-mono repo style groups as well as for large organizations where teams have separate repo ownership for the same AWS account.

## Debugging features
The `assume_role_names` input allows you to assume the OIDC role and act as if you were the GitHub Actions pipeline.
This is very useful for debugging while you're getting things setup.
Note: we recommend removing this once your production ready so that all further changes are only applied via the pipeline.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_oidc_github"></a> [aws\_oidc\_github](#module\_aws\_oidc\_github) | modules/aws-roles-oidc-github | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [tls_certificate.github](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aud_value"></a> [aud\_value](#input\_aud\_value) | GitHub Aud | `string` | `"sts.amazonaws.com"` | no |
| <a name="input_github_tls_url"></a> [github\_tls\_url](#input\_github\_tls\_url) | GitHub URL to perform TLS verification against. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration in seconds. - by default assume role will be 15 minutes - when calling from actions you'll need to increase up to the maximum allowed hwere | `number` | `3600` | no |
| <a name="input_role_subject-repos_policies"></a> [role\_subject-repos\_policies](#input\_role\_subject-repos\_policies) | role name to repos and policies mapping. role name as the key and object value for repo subjects ie "repo:organization/infrastructure:ref:refs/heads/main" as well as a list of policy arns ie ["Administrator"] and list of roles that can assume the new role for debugging | <pre>map(object({<br>    subject_repos    = list(string)<br>    policy_arns = list(string)<br>    assume_role_names = optional(list(string))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#output\_github\_oidc\_provider\_arn) | oidc provider arn to use for roles/policies |
| <a name="output_github_oidc_provider_url"></a> [github\_oidc\_provider\_url](#output\_github\_oidc\_provider\_url) | oidc provider url to use for roles/policies |
| <a name="output_iam_role_arns"></a> [iam\_role\_arns](#output\_iam\_role\_arns) | Roles that will be assumed by GitHub Action |
<!-- END_TF_DOCS -->