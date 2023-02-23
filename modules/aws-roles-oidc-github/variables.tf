variable "github_oidc_provider_arn" {
  type = string
  description = "arn to the provider for which the role will be allowed with"
}

variable "github_oidc_provider_url" {
  type = string
  description = "url to the provider for which the role will be allowed with"
}

variable "github_repos" {
  type        = list(string)
  description = "A list of repositories the OIDC role should have access to."
}

variable "role_name" {
  description = "The name of the OIDC role. Note: this will be prefixed with 'github-role-' and any special characters will be replaced with '-'."
  type        = string
}

variable "policy_arns" {
  type        = list(string)
  description = "Policy arns to attach to the OIDC role."
}

variable "assume_role_names" {
  description = "List of roles that can assume the OIDC role. Useful for debugging cluster before aws-config is updated."
  type        = list(string)
  default     = []
}

variable "max_session_duration" {
  type = number
  description = "Maximum session duration in seconds. - by default assume role will be 15 minutes - when calling from actions you'll need to increase up to the maximum allowed hwere"
  default = 3600
}