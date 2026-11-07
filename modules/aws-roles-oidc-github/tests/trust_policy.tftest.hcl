# Plan-only checks of the rendered trust policy. Runs offline: the policy
# document is computed locally and account lookups are overridden.

provider "aws" {
  region                      = "us-west-2"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

override_data {
  target = data.aws_caller_identity.current
  values = { account_id = "123456789012" }
}

override_data {
  target = data.aws_partition.current
  values = { partition = "aws" }
}

variables {
  role_name                = "gh-apply"
  role_path                = "/"
  github_repos             = ["repo:org/repo:ref:refs/heads/main"]
  policy_arns              = []
  github_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  github_oidc_provider_url = "https://token.actions.githubusercontent.com"
}

run "no_assume_role_names" {
  command = plan

  assert {
    condition     = length(jsondecode(data.aws_iam_policy_document.assume_role_policy.json).Statement) == 1
    error_message = "Expected only the web identity statement."
  }
}

run "null_assume_role_names" {
  command = plan

  variables {
    assume_role_names = null
  }

  assert {
    condition     = length(jsondecode(data.aws_iam_policy_document.assume_role_policy.json).Statement) == 1
    error_message = "null must behave like an empty list."
  }
}

run "several_assume_role_names_share_one_statement" {
  command = plan

  variables {
    assume_role_names = ["admin-a", "admin-b", "admin-c"]
  }

  assert {
    condition     = length(jsondecode(data.aws_iam_policy_document.assume_role_policy.json).Statement) == 2
    error_message = "Expected the web identity statement plus exactly one sts:AssumeRole statement."
  }

  assert {
    condition = jsonencode(sort(jsondecode(data.aws_iam_policy_document.assume_role_policy.json).Statement[1].Principal.AWS)) == jsonencode([
      "arn:aws:iam::123456789012:role/admin-a",
      "arn:aws:iam::123456789012:role/admin-b",
      "arn:aws:iam::123456789012:role/admin-c",
    ])
    error_message = "The sts:AssumeRole statement must list every role ARN once."
  }
}
