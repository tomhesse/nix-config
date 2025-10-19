{ pkgs, ... }:
{
  fonts.packages = builtins.attrValues { inherit (pkgs) fira-sans; };
}
