output "ROLE_ARN" {
  description = "Role that will be assumed by GitHub actions"
  value       = aws_iam_role.github_ci.arn
}
