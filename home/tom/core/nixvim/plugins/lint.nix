{ pkgs, ... }:
{
  extraPackages = builtins.attrValues {
    inherit (pkgs)
      deadnix
      markdownlint-cli
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
      markdown = [
        "markdownlint"
      ];
      nix = [
        "nix"
        "deadnix"
        "statix"
      ];
    };
  };
}
