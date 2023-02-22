variable "role_subject-repos_policies" {
  type = map(object({
    subject_repos    = list(string)
    policy_names = list(string)
    assume_role_names = optional(list(string))
  }))
  description = "role name to repos and policies mapping. role name as the key and object value for repo subjects ie \"repo:organization/infrastructure:ref:refs/heads/main\" as well as a list of policy names ie [\"Administrator\"] and list of roles that can assume the new role for debugging"
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