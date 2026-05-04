{
  flake.modules.homeManager.beets =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      fishEnabled = config.programs.fish.enable;
      mpdEnabled = config.services.mpd.enable;
    in
    {
      home.persistence."/persistent" = {
        files = [
          "${config.xdg.relativeDataHome}/beets/musiclibrary.db"
        ]
        ++ lib.optional fishEnabled "${config.xdg.relativeConfigHome}/fish/completions/beet.fish";
      };

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
            musicbrainz.enable = true;
            replaygain.enable = true;
          }
          // lib.optionalAttrs mpdEnabled { mpdupdate.enable = true; }
          // lib.optionalAttrs fishEnabled { fish.enable = true; };
        };
        settings = {
          library = "${config.xdg.dataHome}/beets/musiclibrary.db";
          directory = "/mnt/music";
          plugins = [
            "autobpm"
            "convert"
            "fetchart"
            "info"
            "inline"
            "lastgenre"
            "musicbrainz"
            "replaygain"
          ]
          ++ lib.optional mpdEnabled "mpdupdate"
          ++ lib.optional fishEnabled "fish";
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
          replaygain.backend = "ffmpeg";
        };
      };
    };
}
