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
      excludes = [ "facter\\.json$" ];
    };

    # Misc
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    detect-private-keys.enable = true;

    # Nix
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;

    # Shell
    shellcheck.enable = true;

    # Secrets
    ripsecrets = {
      enable = true;
      excludes = [ "\\.pub$" ];
    };

    # Spell checker
    typos = {
      enable = true;
      excludes = [ "\\.asc$" ];
      settings = {
        ignored-words = [
          "facter"
          "iy"
        ];
        exclude = [
          "facter.json"
          "secrets/"
        ];
      };
    };
  };
}
