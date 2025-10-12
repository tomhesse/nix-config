{ config, lib, ... }:
let
  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      "${relativeDataHome}/fish/generated_completions"
    ];
    files = [
      "${relativeDataHome}/fish/fish_history"
    ];
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
  };
}
