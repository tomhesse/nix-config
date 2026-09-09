{ self, ... }:
{
  flake.modules.nixos.syncoid = {
    imports = [ self.modules.nixos.notify-failure ];

    services.syncoid = {
      enable = true;
      interval = "*:15";
      commonArgs = [ "--no-sync-snap" ];
      service.onFailure = [ "notify-failure@%N.service" ];
    };
  };
}
