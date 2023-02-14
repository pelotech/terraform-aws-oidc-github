variable "assume_role_names" {
  description = "List of roles that can assume the OIDC role. Useful for debugging cluster before aws-config is updated."
  type        = list(string)
  default     = []
}

variable "subject_roles" {
  type = map(list(string))
  description = "Subject to role mapping. Ex: repo:organization/infrastructure:ref:refs/heads/main -> [AdministratorAccess, AmazonS3FullAccess, CustomUserPolicyOne]"
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

variable "match_field" {
  type        = string
  default     = "sub"
  description = "GitHub match_field."
}

variable "max_session_duration" {
  type = number
  description = "Maximum session duration in seconds. - by default assume role will be 15 minutes - when calling from actions you'll need to increase up to the maximum allowed hwere"
  default = 3600
}