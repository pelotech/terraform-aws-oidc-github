terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = "~> 4.0.3"
  }
}


data "tls_certificate" "github" {
  url = var.github_tls_url
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = var.github_tls_url
  client_id_list  = [var.aud_value]
  thumbprint_list = [data.tls_certificate.github.certificates.0.sha1_fingerprint]
}

module "aws_oidc_github" {
  for_each             = var.role_subject-repos_policies
  source               = "modules/aws-roles-oidc-github"
  role_name            = each.key
  github_repos         = each.value.subject_repos
  policy_arns         = each.value.policy_arns
  assume_role_names    = each.value.assume_role_names
  github_oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
  github_oidc_provider_url = aws_iam_openid_connect_provider.github.url
  max_session_duration = var.max_session_duration
}