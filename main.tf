terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.39.0"
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = var.github_tls_url
  client_id_list = [var.aud_value]
  tags           = var.tags
}

module "aws_oidc_github" {
  for_each                 = var.roles
  source                   = "./modules/aws-roles-oidc-github"
  role_name                = each.key
  role_path                = each.value.role_path
  github_repos             = each.value.subject_repos
  policy_arns              = each.value.policy_arns
  assume_role_names        = each.value.assume_role_names
  github_oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
  github_oidc_provider_url = aws_iam_openid_connect_provider.github.url
  max_session_duration     = var.max_session_duration
  tags                     = var.tags
}
