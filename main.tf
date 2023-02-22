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
  for_each             = var.role_subject-repos_policies
  source               = "./modules/aws-oidc-github"
  role_name            = each.key
  github_repos         = each.value.subject_repos
  policy_names         = each.value.policy_names
  assume_role_names    = each.value.assume_role_names
  aud_value            = var.aud_value
  github_tls_url       = var.github_tls_url
  max_session_duration = var.max_session_duration
}