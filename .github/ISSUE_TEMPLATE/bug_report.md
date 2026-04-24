---
name: Bug report
about: Something not working as expected
title: ""
labels: bug
assignees: ""
---

## What happened

<!-- 1–2 sentences. What did you expect, what did you see instead? -->

## Module / provider versions

- Module version: (e.g. `v1.0.0`)
- Terraform: (output of `terraform version`)
- aws provider: (from `.terraform.lock.hcl`)

## Relevant configuration

<details><summary>module block</summary>

```hcl
# paste the module "aws_oidc_github" { … } block here
```

</details>

## `terraform plan` / `apply` output

<details><summary>output</summary>

```
# redact account IDs / role ARNs as needed
```

</details>

## For OIDC assume-role failures only

If the workflow hits "Not authorized to perform sts:AssumeRoleWithWebIdentity", please include:

- The `Configure AWS Credentials` step output with `debug: true`, **or**
- The `sub` claim value GitHub sent (visible in the step log when debug is on).

This is almost always a subject-claim mismatch and the diff is obvious once both strings are side by side.
