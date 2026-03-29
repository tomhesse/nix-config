{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        inputsFrom = [ config.pre-commit.devShell ];
        packages = with pkgs; [
          nix-diff
          nix-output-monitor
          nix-tree
        ];
      };
    };
}
