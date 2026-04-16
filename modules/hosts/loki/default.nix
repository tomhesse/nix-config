{ self, ... }:
{
  configurations.nixos.loki.module = {
    imports = [
      self.diskoConfigurations.loki
      self.modules.nixos.desktop
      self.modules.nixos.framework-13-7040-amd
      self.modules.nixos.secure-boot
      self.modules.nixos.user-thesse
    ];

    home-manager.users.thesse.imports = [ self.modules.homeManager.desktop ];

    hardware.facter.reportPath = ./facter.json;

    monitors = {
      eDP-1 = {
        resolution = "2880x1920";
        refreshRate = 120;
        scale = 2;
        primary = true;
        workspaces = [
          1
          2
          3
          4
          5
        ];
      };
    };

    time.timeZone = "Europe/Berlin";

    networking.hostName = "loki";

    system.stateVersion = "25.11";
  };
}
