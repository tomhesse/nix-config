{
  flake.modules.homeManager.feishin =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.feishin ];

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeConfigHome}/feishin"
      ];
    };
}
