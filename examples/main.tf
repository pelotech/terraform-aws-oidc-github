terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.39.0"
    }
  }
}

provider "aws" {
  alias  = "my_alias"
  region = "eu-west-2"
}

module "aws_oidc_github" {
  source = "pelotech/oidc-github/aws"
  providers = {
    aws = aws.my_alias
  }

  roles = {
    # A role scoped to the `main` branch of one repo, granted Administrator,
    # and additionally assumable by an SSO role for local debugging.
    "org-infra-main" = {
      role_path         = "/some-role-path/"
      subject_repos     = ["repo:organization/infrastructure:ref:refs/heads/main"]
      policy_arns       = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      assume_role_names = ["aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_SomeManagedpolicy_XXXXXXXXXXXXXXXXX"]
    }

    # A read-only role usable from any branch of the same repo.
    "org-infra-all-branches" = {
      subject_repos = ["repo:organization/infrastructure:ref:refs/heads/*"]
      policy_arns   = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
    }
  }
}
