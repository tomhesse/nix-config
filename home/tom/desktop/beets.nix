{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    optionalAttrs
    optional
    ;

  cfg = config.homeSpec.desktop.beets;

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;
  fishEnabled = osConfig.hostSpec.shells.fish.enable;

  relativeConfigHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome;
  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  options.homeSpec.desktop.beets.enable = mkEnableOption "Install and configure beets.";

  config = mkIf cfg.enable {
    programs.beets = {
      enable = true;
      package = pkgs.python3.pkgs.beets.override {
        pluginOverrides = {
          autobpm.enable = true;
          convert.enable = true;
          fetchart.enable = true;
          info.enable = true;
          inline.enable = true;
          lastgenre.enable = true;
          mpdupdate.enable = true;
          musicbrainz.enable = true;
          replaygain.enable = true;
        }
        // optionalAttrs fishEnabled { fish.enable = true; };
      };
      settings = {
        library = "${config.xdg.dataHome}/beets/musiclibrary.db";
        directory = "${config.xdg.userDirs.music}";
        plugins = [
          "autobpm"
          "convert"
          "fetchart"
          "info"
          "inline"
          "lastgenre"
          "mpdupdate"
          "musicbrainz"
          "replaygain"
        ]
        ++ optional fishEnabled "fish";
        per_disc_numbering = true;
        ui.color = true;
        import = {
          move = true;
          bell = true;
          timid = true;
        };
        match.preferred = {
          countries = [
            "DE"
            "XE"
            "XW"
          ];
          media = [
            "CD"
            "Digital Media|File"
          ];
        };
        paths = {
          default = "$albumartist/$year - $album%aunique{}/%if{$multidisc,Disc $disc/}$track - $title";
          singleton = "Non-Album/$artist/$title";
          comp = "Compilations/$year - $album%aunique{}/$track - $artist - $title";
        };
        item_fields.multidisc = "1 if disctotal > 1 else 0";
        convert.dest = "${config.xdg.userDirs.extraConfig.XDG_TEMP_DIR}/MP3s";
        replaygain = {
          backend = "ffmpeg";
        };
      };
    };

    home.persistence = mkIf impermanenceEnabled {
      "/persist${config.home.homeDirectory}" = {
        files = [
          "${relativeDataHome}/beets/musiclibrary.db"
        ]
        ++ optional fishEnabled "${relativeConfigHome}/fish/completions/beet.fish";
      };
    };
  };
}
