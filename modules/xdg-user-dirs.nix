{
  flake.modules.homeManager.xdg-user-dirs =
    { config, lib, ... }:
    let
      cfg = config.xdg.userDirs;
      mkRelative = path: lib.removePrefix "${config.home.homeDirectory}/" path;

      standardDirs = builtins.filter (p: p != null) [
        cfg.documents
        cfg.download
        cfg.music
        cfg.pictures
        cfg.videos
      ];

      extraDirs = builtins.attrValues cfg.extraConfig;
    in
    {
      xdg.userDirs = {
        enable = true;

        desktop = null;
        publicShare = null;
        templates = null;
        documents = "${config.home.homeDirectory}/documents";
        download = "${config.home.homeDirectory}/downloads";
        music = "${config.home.homeDirectory}/music";
        pictures = "${config.home.homeDirectory}/pictures";
        videos = "${config.home.homeDirectory}/videos";

        extraConfig = {
          GAMES = "${config.home.homeDirectory}/games";
          PROJECTS = "${config.home.homeDirectory}/projects";
          TEMP = "${config.home.homeDirectory}/temp";
        };
      };

      home.persistence."/persistent".directories = map mkRelative (standardDirs ++ extraDirs);
    };
}
