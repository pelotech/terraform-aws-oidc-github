output "iam_role_arn" {
  description = "ARN of the IAM role that GitHub Actions assumes. Pass it as `role-to-assume` in the workflow."
  value       = aws_iam_role.github_ci.arn
}

output "iam_role_name" {
  description = "Name of the IAM role created for this GitHub Actions entry."
  value       = aws_iam_role.github_ci.name
}
