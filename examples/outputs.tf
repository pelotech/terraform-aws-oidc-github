output "iam_role_arns_map" {
  description = "Map of role name to IAM role ARN. Use these as `role-to-assume` in your workflows."
  value       = module.aws_oidc_github.iam_role_arns_map
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider created by the example."
  value       = module.aws_oidc_github.github_oidc_provider_arn
}
