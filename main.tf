terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = "~> 4.0.3"
  }
}

module "aws_oidc_github" {
  for_each             = var.subject_roles
  source               = "./modules/aws-oidc-github"
  role_name            = replace(each.key, "/\\W/", "-")
  github_repos         = [each.key]
  managed_policy_names = each.value
  assume_role_names    = var.assume_role_names
  match_field          = var.match_field
  aud_value            = var.aud_value
  github_tls_url       = var.github_tls_url
  max_session_duration = var.max_session_duration
}