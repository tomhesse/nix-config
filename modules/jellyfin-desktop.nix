{
  flake.modules.homeManager.jellyfin-desktop =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.jellyfin-desktop ];

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/jellyfin-desktop"
      ];
    };
}
