{ inputs, ... }:
{
  imports = [ inputs.git-hooks-nix.flakeModule ];

  flake-file.inputs.git-hooks-nix = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem.pre-commit.settings.hooks = {
    # Editorconfig
    editorconfig-checker.enable = true;

    # Misc
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    detect-private-keys.enable = true;

    # Nix
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;

    # Secrets
    ripsecrets.enable = true;

    # Spell checker
    typos.enable = true;
  };
}
