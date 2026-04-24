variable "roles" {
  type = map(object({
    role_path         = optional(string, "/")
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

  validation {
    condition = alltrue([
      for v in var.roles : alltrue([for r in v.subject_repos : startswith(r, "repo:")])
    ])
    error_message = "Every subject_repos entry must start with \"repo:\" (e.g. \"repo:my-org/my-repo:ref:refs/heads/main\")."
  }

  validation {
    condition = alltrue([
      for v in var.roles : can(regex("^/([a-zA-Z0-9._+-]+/)*$", v.role_path))
    ])
    error_message = "Each role_path must start and end with '/' and only contain [a-zA-Z0-9._+-] segments (e.g. \"/\", \"/github/\", \"/teams/platform/\")."
  }

  validation {
    condition = alltrue([
      for name, _ in var.roles : can(regex("^[a-zA-Z0-9+=,.@_-]{1,64}$", name))
    ])
    error_message = "Each role name (the map key in var.roles) must be 1–64 characters and match the IAM-allowed charset [a-zA-Z0-9+=,.@_-]."
  }

  validation {
    condition = alltrue([
      for v in var.roles : alltrue([
        for arn in v.policy_arns : can(regex("^arn:aws[a-z0-9-]*:iam::(aws|[0-9]{12}):policy/", arn))
      ])
    ])
    error_message = "Every policy_arns entry must be a valid IAM policy ARN (e.g. \"arn:aws:iam::aws:policy/ReadOnlyAccess\" or \"arn:aws:iam::123456789012:policy/my-policy\")."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the OIDC provider and every IAM role created by this module."
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

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 (1h) and 43200 (12h) — AWS-enforced bounds."
  }
}
