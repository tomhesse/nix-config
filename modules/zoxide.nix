{
  flake.modules.homeManager.zoxide =
    { config, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/zoxide"
      ];

      programs.zoxide.enable = true;
    };
}
