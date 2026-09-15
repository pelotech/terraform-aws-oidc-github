{
  description = "Flake config";

  nixConfig = {
    # Pre-built Terraform binaries from nixpkgs-terraform; avoids building from source.
    extra-substituters = "https://nixpkgs-terraform.cachix.org";
    extra-trusted-public-keys = "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw=";
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        let
          # Pin the dev shell to the minimum Terraform version the module supports,
          # taken from `required_version = ">= X.Y.Z"` in main.tf.
          tfVersion = builtins.head (
            builtins.match ".*required_version[[:space:]]*=[[:space:]]*\">= ([0-9.]+)\".*" (
              builtins.readFile ./main.tf
            )
          );
          terraform = inputs.nixpkgs-terraform.packages.${system}."terraform-${tfVersion}";

          # Everything pre-commit needs; this is all CI installs.
          lintTools = with pkgs; [
            terraform
            prek
            tflint
            hcledit
            yamllint
            terraform-docs
            actionlint
            zizmor
          ];
        in
        {
          devShells.ci = pkgs.mkShellNoCC { packages = lintTools; };

          devShells.default = pkgs.mkShellNoCC {
            packages =
              lintTools
              ++ (with pkgs; [
                # sops
                rage
                age-plugin-yubikey
                sops

                # aws
                awscli2
                aws-sso-cli

                just
              ]);
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.terraform.enable = true;
            programs.terraform.package = terraform;
            programs.nixfmt.enable = true;
          };
        };
    };
}
