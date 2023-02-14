terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = "~> 4.0.3"
  }
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "tls_certificate" "github" {
  url = var.github_url
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = var.github_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_repos
    }
  }
  dynamic "statement" {
    for_each = var.assume_role_names
    content {
      actions = ["sts:AssumeRole"]
      principals {
        identifiers = formatlist(
          "arn:%s:iam::%s:role/%s",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id,
          var.assume_role_names
        )
        type = "AWS"
      }
    }
  }
}

resource "aws_iam_role" "github_ci" {
  name               = format("GithubCI-OIDC-%s", var.role_name)
  description        = "Role assumed by Github Actions with OIDC"
  max_session_duration = var.max_session_duration
  path               = "/ci/"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  managed_policy_arns = formatlist(
    "arn:%s:iam::aws:policy/%s",
    data.aws_partition.current.partition,
    var.managed_policy_names
  )
}
