{
  flake.modules.homeManager.trash =
    { config, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/Trash"
      ];
    };
}
