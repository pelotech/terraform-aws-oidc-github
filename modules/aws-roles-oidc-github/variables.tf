variable "github_oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub OIDC provider that the IAM role will trust."
}

variable "github_oidc_provider_url" {
  type        = string
  description = "URL of the GitHub OIDC provider (e.g. https://token.actions.githubusercontent.com)."
}

variable "github_repos" {
  type        = list(string)
  description = "Subject claims (repo:org/repo:ref:refs/heads/main, repo:org/repo:environment:prod, etc.) the role will allow to assume it."
}

variable "role_name" {
  type        = string
  description = "Name of the IAM role to create. Used verbatim — no prefixing or sanitization is applied."
}

variable "role_path" {
  type        = string
  description = "IAM path to create the role under. Must start and end with '/' (e.g. '/' or '/github/')."

  validation {
    condition     = can(regex("^/([a-zA-Z0-9._+-]+/)*$", var.role_path))
    error_message = "role_path must start and end with '/' and only contain [a-zA-Z0-9._+-] segments (e.g. \"/\", \"/github/\", \"/teams/platform/\")."
  }
}

variable "policy_arns" {
  type        = list(string)
  description = "IAM policy ARNs to attach to the role (managed or customer-managed policies)."
}

variable "assume_role_names" {
  type        = list(string)
  default     = []
  description = "IAM role names in the same account that may assume this role via sts:AssumeRole. Useful for local debugging; remove before production."
}

variable "max_session_duration" {
  type        = number
  default     = 3600
  description = "Maximum session duration in seconds for the role. Defaults to 1 hour. Increase up to 43200 (12h) if your workflows need longer sessions."

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 (1h) and 43200 (12h) — AWS-enforced bounds."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the IAM role created by this submodule."
}
