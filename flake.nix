{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    catppuccin = {
      url = "github:catppuccin/nix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-parts, nixpkgs, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.devshell.flakeModule
        inputs.git-hooks.flakeModule
      ];

      flake =
        let
          hostsDir = ./hosts;
          hostsDirEntries = builtins.readDir hostsDir;
          hostNames = builtins.filter (
            name: hostsDirEntries.${name} == "directory" && builtins.substring 0 1 name != "."
          ) (builtins.attrNames hostsDirEntries);

          mkHost =
            { hostNames, name }:
            nixpkgs.lib.nixosSystem {
              specialArgs = {
                hostName = name;
                inherit hostNames inputs;
              };
              modules = [
                ./modules/core
                ./modules/disko
                (hostsDir + "/${name}")
              ];
            };
        in
        {
          nixosConfigurations = nixpkgs.lib.genAttrs hostNames (name: mkHost { inherit hostNames name; });
        };

      perSystem =
        { config, pkgs, ... }:
        {
          devshells.default =
            { extraModulesPath, ... }:
            {
              imports = [ "${extraModulesPath}/git/hooks.nix" ];

              commands = [
                {
                  name = "lint";
                  help = "Lint with statix & deadnix";
                  command = "statix check . && deadnix .";
                }
              ];

              env = [
                {
                  name = "NIX_CONFIG";
                  value = "experimental-features = nix-command flakes";
                }
              ];

              motd = ''
                nix-config dev shell
                Native commands available:
                - nix fmt -> Format nix files
                - nix flake check -> Validate flakes
                - nix flake update -> Update inputs
                Extra commands:
                - lint -> Run statix & deadnix
              '';

              packages = builtins.attrValues {
                inherit (pkgs)
                  deadnix
                  git
                  gnupg
                  home-manager
                  sops
                  ssh-to-age
                  statix
                  ;
              };

              git.hooks.enable = true;

              # Install git-hooks to .git/hooks
              devshell.startup.pre-commit.text = config.pre-commit.installationScript;
            };

          formatter = pkgs.nixfmt-tree;

          pre-commit.settings.hooks = {
            # General
            check-added-large-files.enable = true;
            check-case-conflicts.enable = true;
            check-executables-have-shebangs.enable = true;
            check-merge-conflicts.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            detect-private-keys.enable = true;
            editorconfig-checker.enable = true;
            end-of-file-fixer.enable = true;
            fix-byte-order-marker.enable = true;
            mixed-line-endings.enable = true;
            trim-trailing-whitespace.enable = true;
            typos = {
              enable = true;
              excludes = [
                "secrets.yaml"
              ];
            };

            # Markdown
            markdownlint.enable = true;

            # Nix
            deadnix.enable = true;
            nixfmt-rfc-style.enable = true;
            statix.enable = true;

            # Shellscripts
            shellcheck.enable = true;
            shfmt.enable = true;
          };
        };
    };
}
