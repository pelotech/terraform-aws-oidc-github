output "iam_role_arns_map" {
  description = "Map of role name to IAM role ARN."
  value       = { for k, m in module.aws_oidc_github : k => m.iam_role_arn }
}

output "github_oidc_provider_arn" {
  description = "oidc provider arn to use for roles/policies"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_oidc_provider_url" {
  description = "oidc provider url to use for roles/policies"
  value       = aws_iam_openid_connect_provider.github.url
}
