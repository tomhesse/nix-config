{ self, ... }:
{
  configurations.nixos.loki.module = {
    imports = [
      self.diskoConfigurations.loki
      self.modules.nixos.desktop
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
      };
    };

    networking.hostName = "loki";

    system.stateVersion = "25.11";
  };
}
