{
  description = "Flake config";

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
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # terraform, pinned to required_version floor
              terraform

              # sops
              rage
              age-plugin-yubikey
              sops

              # aws
              awscli2
              aws-sso-cli

              just

              # pre-commit
              prek
              tflint
              hcledit
              yamllint
              terraform-docs
              actionlint
              zizmor

            ];
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
