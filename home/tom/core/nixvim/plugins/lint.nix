{ pkgs, ... }:
{
  extraPackages = builtins.attrValues {
    inherit (pkgs)
      deadnix
      nix
      statix
      ;
  };
  plugins.lint = {
    enable = true;
    autoCmd.event = [
      "BufEnter"
      "BufWritePost"
      "InsertLeave"
    ];
    lintersByFt = {
      nix = [
        "nix"
        "deadnix"
        "statix"
      ];
    };
  };
}
