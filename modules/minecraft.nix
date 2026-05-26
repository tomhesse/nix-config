{
  flake.modules.homeManager.minecraft =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.prismlauncher ];

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/PrismLauncher"
      ];
    };
}
