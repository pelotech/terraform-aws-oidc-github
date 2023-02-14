output "iam_role_arn" {
  description = "Role that will be assumed by GitHub Action"
  value       = values(module.aws_oidc_github)[*].iam_role_arn
}
