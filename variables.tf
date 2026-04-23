variable "role_subject-repos_policies" {
  type = map(object({
    role_path         = optional(string)
    subject_repos     = list(string)
    policy_arns       = list(string)
    assume_role_names = optional(list(string))
  }))
  description = <<-EOT
    Map of IAM roles to create. The map key is the role name. Each value defines:
      - `subject_repos`     : OIDC subject claims allowed to assume this role (e.g. "repo:my-org/my-repo:ref:refs/heads/main").
      - `policy_arns`       : IAM policy ARNs to attach to the role.
      - `role_path`         : (optional) IAM path for the role. Defaults to "/".
      - `assume_role_names` : (optional) IAM role names in the same account that may also assume this role (useful for local debugging).
  EOT
}

variable "github_tls_url" {
  type        = string
  default     = "https://token.actions.githubusercontent.com"
  description = "GitHub OIDC issuer URL. Override only for GitHub Enterprise Server."
}

variable "aud_value" {
  type        = string
  default     = "sts.amazonaws.com"
  description = "Audience claim required in the OIDC token. Defaults to the value the official aws-actions/configure-aws-credentials action sends."
}

variable "max_session_duration" {
  type        = number
  default     = 3600
  description = "Maximum session duration in seconds for every role created. Defaults to 1 hour. Increase up to 43200 (12h) if your workflows need longer sessions."
}
