output "iam_role_arn" {
  description = "Role that will be assumed by GitHub Action"
  value       = aws_iam_role.github_ci.arn
}
