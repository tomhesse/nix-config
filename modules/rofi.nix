{
  flake.modules.homeManager.rofi =
    { config, ... }:
    {
      home.persistence."/persistent".files = [
        "${config.xdg.relativeCacheHome}/rofi-entry-history.txt"
        "${config.xdg.relativeCacheHome}/rofi3.druncache"
      ];

      programs.rofi = {
        enable = true;
        font = "Fira Sans 12";
        extraConfig = {
          run-command = "uwsm app -- {cmd}";
          kb-row-up = "Up,Alt+k";
          kb-row-down = "Down,Alt+j";
        };
      };
    };
}
