{ self, ... }:
{
  flake.modules.nixos.sanoid = {
    imports = [ self.modules.nixos.notify-failure ];

    services.sanoid = {
      enable = true;

      templates = {
        archive = {
          hourly = 0;
          daily = 0;
          weekly = 8;
          monthly = 0;
          autosnap = true;
          autoprune = true;
        };

        homeassistant = {
          hourly = 0;
          daily = 30;
          monthly = 0;
          autosnap = true;
          autoprune = true;
        };

        media = {
          hourly = 0;
          daily = 0;
          weekly = 8;
          monthly = 0;
          autosnap = true;
          autoprune = true;
        };

        replica = {
          hourly = 48;
          daily = 30;
          monthly = 0;
          autosnap = false;
          autoprune = true;
        };

        restic = {
          hourly = 0;
          daily = 30;
          monthly = 0;
          autosnap = true;
          autoprune = true;
        };

        services = {
          hourly = 48;
          daily = 14;
          monthly = 0;
          autosnap = true;
          autoprune = true;
        };

        timemachine = {
          hourly = 0;
          daily = 14;
          monthly = 0;
          autosnap = true;
          autoprune = true;
        };

        system = {
          hourly = 24;
          daily = 30;
          monthly = 0;
          autosnap = true;
          autoprune = true;
        };
      };
    };

    systemd.services.sanoid.onFailure = [ "notify-failure@sanoid.service" ];
  };
}
