{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    inherit (pkgs)
      wiremix
      wl-clipboard
      yubikey-manager
      ;
  };
}
