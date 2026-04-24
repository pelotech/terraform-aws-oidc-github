output "iam_role_arn" {
  description = "Role that will be assumed by GitHub Action"
  value       = aws_iam_role.github_ci.arn
}

output "iam_role_name" {
  description = "Name of the IAM role created for this GitHub Actions entry."
  value       = aws_iam_role.github_ci.name
}
