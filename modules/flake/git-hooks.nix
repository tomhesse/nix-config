{ inputs, ... }:
{
  imports = [ inputs.git-hooks-nix.flakeModule ];

  flake-file.inputs.git-hooks-nix = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem.pre-commit.settings.hooks = {
    # Editorconfig
    editorconfig-checker = {
      enable = true;
      excludes = [
        "\\.jwe$"
        "\\.mcp\\.json$"
        "facter\\.json$"
      ];
    };

    # Misc
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    detect-private-keys.enable = true;

    # Nix
    deadnix.enable = true;
    nixfmt.enable = true;
    statix = {
      enable = true;
      excludes = [ "^.direnv/" ];
    };

    # Shell
    shellcheck = {
      enable = true;
      excludes = [ "^\\.envrc$" ];
    };

    # Secrets
    ripsecrets = {
      enable = true;
      excludes = [
        "\\.asc$"
        "\\.pub$"
      ];
    };

    # Spell checker
    typos = {
      enable = true;
      excludes = [ "\\.asc$" ];
      settings = {
        ignored-words = [
          "facter"
          "iy"
          "lazer"
          "ND"
          "ADN"
        ];
        exclude = [
          "*.jwe"
          "facter.json"
          "secrets/"
        ];
      };
    };
  };
}
