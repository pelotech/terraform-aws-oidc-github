# Migrating from v0.x to v1.0.0

v1.0.0 is the first breaking release of this module. The code changes are small and mechanical; the `terraform plan` against an existing v0.6.x deployment will show a few expected diffs, none of which replace resources.

## TL;DR

1. Rename the module input `role_subject-repos_policies` → `roles`.
2. Replace references to the `iam_role_arns` output with `iam_role_arns_map["<role-name>"]`.
3. Bump your AWS provider floor to `>= 5.39.0`.
4. `terraform plan`, review, `terraform apply`.

No resources are replaced. No live privilege gap on IAM role policy attachments.

## Version floors

| Component              | v0.x            | v1.0.0            |
| ---------------------- | --------------- | ----------------- |
| Terraform              | `>= 1.5.7`      | `>= 1.5.7`        |
| `hashicorp/aws`        | `>= 4.0`        | `>= 5.39.0`       |
| `hashicorp/tls`        | `>= 4.0.3` *    | (not required)    |

\* The `tls` provider was already dropped in v0.6.0; it's listed here only if your own root module still declares it on our behalf.

`aws >= 5.39.0` is required because v1.0.0 drops `thumbprint_list` from the OIDC provider resource, which the AWS provider made optional in [hashicorp/terraform-provider-aws#37278](https://github.com/hashicorp/terraform-provider-aws/pull/37278).

## Step 1 — Rename `role_subject-repos_policies` → `roles`

The object shape is unchanged, only the variable name differs.

```diff
 module "aws_oidc_github" {
   source  = "pelotech/oidc-github/aws"
-  version = "~> 0.6"
+  version = "~> 1.0"

-  role_subject-repos_policies = {
+  roles = {
     "deploy-main" = {
       subject_repos = ["repo:my-org/my-repo:ref:refs/heads/main"]
       policy_arns   = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
     }
   }
 }
```

A single find/replace handles it:

```sh
grep -rl 'role_subject-repos_policies' . | xargs sed -i '' 's/role_subject-repos_policies/roles/g'
```

## Step 2 — Switch to the `iam_role_arns_map` output

The flat `iam_role_arns` list (deprecated since v0.6.0) is removed. Use the map output keyed by role name:

```diff
 output "role_arn" {
-  value = module.aws_oidc_github.iam_role_arns[0]
+  value = module.aws_oidc_github.iam_role_arns_map["deploy-main"]
 }
```

## Step 3 — Bump your AWS provider floor

In any root module that pins the AWS provider, make sure the floor is at least `5.39.0`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.39.0"
    }
  }
}
```

## What `terraform plan` will show

Against an existing v0.6.x deployment, expect three kinds of in-place changes. **No resource replacements; any replacement is a bug — please open an issue.**

### OIDC provider: `thumbprint_list` drops out of Terraform management

```
  ~ resource "aws_iam_openid_connect_provider" "github" {
      ~ thumbprint_list = [
          - "6938fd4d98bab03faadb97b34396831e3780aea1",
        ]
        # (other attributes unchanged)
    }
```

AWS-specific behavior to be aware of: when Terraform stops managing `thumbprint_list`, IAM does **not** re-auto-retrieve a thumbprint — the value you set previously persists on the AWS side. For the GitHub issuer this is irrelevant: AWS ignores configured thumbprints for `token.actions.githubusercontent.com` and validates against its own trusted root CA library regardless. No action needed.

### IAM roles: `managed_policy_arns` → separate `aws_iam_role_policy_attachment` resources

v1.0.0 swaps the deprecated `managed_policy_arns` attribute on `aws_iam_role` for standalone `aws_iam_role_policy_attachment` resources (one per policy ARN, managed via `for_each`).

```
  ~ resource "aws_iam_role" "github_ci" {
      ~ managed_policy_arns = [
          - "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
        ] -> (known after apply)
        # (other attributes unchanged)
    }

  + resource "aws_iam_role_policy_attachment" "github_ci" {
      + policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      + role       = "deploy-main"
    }
```

**No live privilege gap.** AWS evaluates the new `aws_iam_role_policy_attachment` before detaching the old `managed_policy_arns` entries, all in the same apply. A workflow that runs mid-apply keeps the policies it had going in.

Terraform `moved` blocks can't migrate an attribute on one resource type to an entirely different resource type, so this is a detach/reattach rather than a state rename. The role itself is **not** replaced.

### Roles appear unchanged

The IAM role resources themselves (`aws_iam_role.github_ci`) should show no diff other than the `managed_policy_arns` drop above. Role ARNs, IDs, and trust policies are untouched.

## Staying on v0.x

Not ready to migrate? Pin to v0.6.x:

```hcl
module "aws_oidc_github" {
  source  = "pelotech/oidc-github/aws"
  version = "~> 0.6"
  # …
}
```

v0.6.x will continue to work but won't receive further development. Plan your migration on a calendar that suits you.

## Questions / issues

Open an issue at <https://github.com/pelotech/terraform-aws-oidc-github/issues> with the relevant `terraform plan` output.
