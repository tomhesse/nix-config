{ config, lib, ... }:
let
  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  programs.zoxide.enable = true;

  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      "${relativeDataHome}/zoxide"
    ];
  };
}
