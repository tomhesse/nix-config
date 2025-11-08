{
  config,
  lib,
  pkgs,
  ...
}:
let
  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  programs.yazi = {
    enable = true;
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "l" ];
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }
        {
          on = [ "p" ];
          run = "plugin smart-paste";
          desc = "Paste into the hovered directory or CWD";
        }
        {
          on = [ "M" ];
          run = "plugin mount";
        }
      ];
    };
    plugins = {
      inherit (pkgs.yaziPlugins) mount;
      inherit (pkgs.yaziPlugins) smart-enter;
      inherit (pkgs.yaziPlugins) smart-paste;
    };
  };

  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      "${relativeDataHome}/Trash"
    ];
  };
}
