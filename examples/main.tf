terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = "~> 4.0.3"
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
  subject_policies = {
    "org-infra-main" = {
      subject_repos = ["repo:organization/infrastructure:ref:refs/heads/main"]
      policy_names = ["AdministratorAccess"]
      assume_role_names = ["aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_SomeManagedpolicy_XXXXXXXXXXXXXXXXX"]
    }
    "org-infra-all-branches"    = {
      subject_repos = ["repo:organization/infrastructure:ref:refs/heads/*"]
      policy_names = ["AmazonS3ReadOnlyAccess"]
    }
  }
}