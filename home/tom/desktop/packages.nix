{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    inherit (pkgs)
      wl-clipboard
      yubikey-manager
      ;
  };
}
