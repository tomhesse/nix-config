{ config, lib, ... }:
let
  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      "${relativeDataHome}/fish"
    ];
  };

  programs.fish = {
    enable = true;
    functions = {
      lfcd = {
        wraps = "lf";
        description = "Terminal file manager (changing directory on exit)";
        body = "cd \"$(command lf -print-last-dir $argv)\"";
      };
    };
    interactiveShellInit = ''
      set fish_greeting
    '';
    shellAbbrs = {
      gpgkick = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
      "--help" = {
        position = "anywhere";
        expansion = "--help | bat -plhelp";
      };
      "-h" = {
        position = "anywhere";
        expansion = "-h | bat -plhelp";
      };
    };
  };
}
