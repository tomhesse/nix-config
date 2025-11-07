{ config, lib, ... }:
let
  relativeUserDir = dir: lib.removePrefix "${config.home.homeDirectory}" dir;
in
{
  xdg = {
    autostart = {
      enable = true;
      readOnly = true;
    };
    userDirs = {
      enable = true;
      desktop = null;
      publicShare = null;
      templates = null;
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/download";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos = "${config.home.homeDirectory}/videos";
      extraConfig = {
        XDG_PROJECTS_DIR = "${config.home.homeDirectory}/projects";
      };
    };
  };

  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      (relativeUserDir config.xdg.userDirs.documents)
      (relativeUserDir config.xdg.userDirs.download)
      (relativeUserDir config.xdg.userDirs.music)
      (relativeUserDir config.xdg.userDirs.pictures)
      (relativeUserDir config.xdg.userDirs.videos)
      (relativeUserDir config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR)
    ];
  };
}
