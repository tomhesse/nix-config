{
  flake.modules.homeManager.direnv =
    { config, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/direnv"
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
      };
    };
}
