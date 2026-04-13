{
  flake.modules.homeManager.ncmpcpp =
    { config, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/ncmpcpp"
        "${config.xdg.relativeDataHome}/lyrics"
      ];

      programs.ncmpcpp = {
        enable = true;
        settings = {
          ncmpcpp_directory = "${config.xdg.dataHome}/ncmpcpp";
          lyrics_directory = "${config.xdg.dataHome}/lyrics";
          mpd_host = config.services.mpd.network.listenAddress;
          mpd_port = toString config.services.mpd.network.port;
          startup_screen = "media_library";
          mouse_support = "no";
          user_interface = "alternative";
          external_editor = "nvim";
        };
      };
    };
}
