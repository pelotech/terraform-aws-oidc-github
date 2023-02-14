terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  alias = "my_alias"
  region = "eu-west-2"
}

module "aws_oidc_github" {
  source = "pelotech/oidc-github/aws"
  providers = {
    aws = aws.my_alias
  }
  role_name                = "TF"
  match_value              = ["repo:organization/repository_name:ref:refs/heads/main"]
  managed_policy_names     = ["SomeManagedpolicy"]
  # Be careful here - they will have the ability to be the role of the oidc and will have the same max permission as the managed policy name state.
  assume_role_names = ["aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_SomeManagedpolicy_XXXXXXXXXXXXXXXXX"]
}