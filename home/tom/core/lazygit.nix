{ config, lib, ... }:
let
  relativeStateHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.stateHome;
in
{
  home.persistence."/persist/${config.home.homeDirectory}" = {
    files = [
      "${relativeStateHome}/lazygit/state.yml"
    ];
  };

  programs.lazygit.enable = true;
}
