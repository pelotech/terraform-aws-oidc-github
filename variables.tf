variable "github_url" {
  type        = string
  default     = "https://token.actions.githubusercontent.com"
  description = "Github URL to perform TLS verification against."
}

variable "github_repos" {
  type        = list(any)
  description = "A list of repositories the OIDC role should have access to."
}

variable "role_name" {
  description = "The name of the OIDC role. Note: this will be prefixed with 'GithubCI-OIDC-'"
  type        = string
}

variable "managed_policy_names" {
  type        = list(any)
  description = "Managed policy names to attach to the OIDC role."
}

variable "assume_role_names" {
  description = "List of roles that can assume the OIDC role. Useful for debuging cluster before aws-config is updated."
  type        = list(string)
  default     = null
}
