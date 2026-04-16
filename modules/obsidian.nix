{
  flake.modules.homeManager.obsidian =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.obsidian ];

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeConfigHome}/obsidian"
      ];
    };
}
