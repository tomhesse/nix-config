{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

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

  home.persistence = mkIf impermanenceEnabled {
    "/persist${config.home.homeDirectory}" = {
      directories = [
        "${relativeDataHome}/Trash"
      ];
    };
  };
}
