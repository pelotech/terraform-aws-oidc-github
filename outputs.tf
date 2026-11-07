output "iam_role_arns_map" {
  description = "Map of role name to IAM role ARN."
  value       = { for k, m in module.aws_oidc_github : k => m.iam_role_arn }
}

output "iam_role_names" {
  description = "Map of role name (the var.roles key) to the created IAM role name. Useful for wiring downstream resources (e.g. aws_iam_role_policy) without parsing the ARN."
  value       = { for k, m in module.aws_oidc_github : k => m.iam_role_name }
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider. Use it to trust GitHub Actions from roles created outside this module."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_oidc_provider_url" {
  description = "Issuer URL of the GitHub OIDC provider. Strip any `https://` prefix to get the host used in trust-policy condition keys such as `<host>:sub`."
  value       = aws_iam_openid_connect_provider.github.url
}
