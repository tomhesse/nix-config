{ config, lib, ... }:
let
  relativeStateHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.stateHome;
in
{
  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      "${relativeStateHome}/wireplumber"
    ];
  };
}
