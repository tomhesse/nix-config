{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        inputsFrom = [ config.pre-commit.devShell ];
        packages = with pkgs; [
          clevis
          home-manager
          just
          nix-diff
          nix-output-monitor
          nix-tree
          sbctl
          sops
          ssh-to-age
        ];
      };
    };
}
