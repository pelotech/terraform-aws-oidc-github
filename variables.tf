variable "assume_role_names" {
  description = "List of roles that can assume the OIDC role. Useful for debugging cluster before aws-config is updated."
  type        = list(string)
  default     = []
}

variable "subject_policies" {
  type = map(object({
    role_name    = string
    policy_names = list(string)
  }))
  description = "Subject to policy mapping. repo:organization/infrastructure:ref:refs/heads/main as the key and object value for the create role name as well as a list of policy names ie [\"Administrator\"] "
}

variable "github_tls_url" {
  type        = string
  default     = "https://token.actions.githubusercontent.com"
  description = "GitHub URL to perform TLS verification against."
}

variable "aud_value" {
  type        = string
  default     = "sts.amazonaws.com"
  description = "GitHub Aud"
}

variable "max_session_duration" {
  type        = number
  description = "Maximum session duration in seconds. - by default assume role will be 15 minutes - when calling from actions you'll need to increase up to the maximum allowed hwere"
  default     = 3600
}