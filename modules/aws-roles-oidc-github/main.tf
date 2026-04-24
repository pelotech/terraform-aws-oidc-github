terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.39.0"
    }
  }
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}



data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }
    condition {
      test     = "StringLike"
      variable = "${trimprefix(var.github_oidc_provider_url, "https://")}:sub"
      values   = var.github_repos
    }

  }
  dynamic "statement" {
    for_each = var.assume_role_names != null ? var.assume_role_names : []
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
  name                 = var.role_name
  path                 = var.role_path
  description          = "GitHubCI with OIDC"
  max_session_duration = var.max_session_duration
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy.json
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "github_ci" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.github_ci.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.github_ci.name
  policy = each.value
}
