{
  flake.modules.homeManager.prismlauncher =
    { config, ... }:
    {
      programs.prismlauncher.enable = true;

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/PrismLauncher"
      ];
    };
}
