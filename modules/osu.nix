{
  flake.modules.homeManager.osu =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.osu-lazer-bin ];

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/osu"
      ];
    };
}
