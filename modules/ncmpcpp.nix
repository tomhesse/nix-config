{
  flake.modules.homeManager.ncmpcpp =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe;
      ncmpcpp = getExe pkgs.ncmpcpp;
      kitty = getExe pkgs.kitty;
    in
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/ncmpcpp"
        "${config.xdg.relativeDataHome}/lyrics"
      ];

      xdg.desktopEntries.ncmpcpp = {
        name = "ncmpcpp";
        exec = "${kitty} --class ncmpcpp ${ncmpcpp}";
        terminal = false;
        categories = [
          "Audio"
          "Music"
        ];
      };

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
