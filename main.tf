terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = var.github_tls_url
  client_id_list = [var.aud_value]
  # AWS stopped enforcing thumbprint verification for the GitHub OIDC issuer in
  # mid-2023, but the AWS provider still requires a 40-char hex value. Pass the
  # historical GitHub thumbprint as a placeholder; the actual trust is enforced
  # by IAM via the provider URL, not this value.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  tags            = var.tags
}

module "aws_oidc_github" {
  for_each                 = var.role_subject-repos_policies
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
