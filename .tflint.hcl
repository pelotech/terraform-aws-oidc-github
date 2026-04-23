plugin "terraform" {
    enabled = true
    preset  = "recommended"
}


plugin "aws" {
    enabled = true
    version = "0.47.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_naming_convention" {
    enabled = true

    # Allow hyphens in variable names to permit the existing
    # `role_subject-repos_policies` variable without a breaking rename.
    variable {
        format = "none"
        custom = "^[a-z][a-z0-9_-]*$"
    }

    # Keep snake_case defaults for everything else.
    module       { format = "snake_case" }
    locals       { format = "snake_case" }
    output       { format = "snake_case" }
    resource     { format = "snake_case" }
    data         { format = "snake_case" }
}
