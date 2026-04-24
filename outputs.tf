output "iam_role_arns" {
  description = "Roles that will be assumed by GitHub Action. (Deprecated: use `iam_role_arns_map` instead; this output will be removed in v2.)"
  value       = values(module.aws_oidc_github)[*].iam_role_arn
}

output "iam_role_arns_map" {
  description = "Map of role name to role ARN. Prefer this output; the flat `iam_role_arns` list will be removed in v2."
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
