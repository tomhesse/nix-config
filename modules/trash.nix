{
  flake.modules.nixos.trash = {
    services.gvfs.enable = true;
  };

  flake.modules.homeManager.trash =
    { config, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/Trash"
      ];
    };
}
