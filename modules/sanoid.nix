{
  flake.modules.nixos.sanoid = {
    services.sanoid = {
      enable = true;

      templates = {
        backups = {
          daily = 2;
          weekly = 1;
          autosnap = true;
          autoprune = true;
        };
        frequent = {
          daily = 7;
          weekly = 4;
          monthly = 3;
          autosnap = true;
          autoprune = true;
        };
        media = {
          daily = 2;
          weekly = 2;
          monthly = 1;
          autosnap = true;
          autoprune = true;
        };
      };
    };
  };
}
