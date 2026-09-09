{ self, ... }:
{
  flake.modules.nixos.sanoid = {
    imports = [ self.modules.nixos.notify-failure ];

    services.sanoid = {
      enable = true;

      templates.services = {
        hourly = 48;
        daily = 14;
        autosnap = true;
        autoprune = true;
      };
    };

    systemd.services.sanoid.onFailure = [ "notify-failure@sanoid.service" ];
  };
}
