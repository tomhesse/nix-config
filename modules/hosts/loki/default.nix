{ self, ... }:
{
  configurations.nixos.loki.module = {
    imports = [
      self.diskoConfigurations.loki
      self.modules.nixos.desktop
      self.modules.nixos.framework-13-7040-amd
      self.modules.nixos.hermes
      self.modules.nixos.impermanence
      self.modules.nixos.nfs-client
      self.modules.nixos.restic
      self.modules.nixos.secure-boot
      self.modules.nixos.user-thesse
    ];

    home-manager.users.thesse.imports = [
      self.modules.homeManager.desktop
      self.modules.homeManager.hermes
    ];

    hardware.facter.reportPath = ./facter.json;

    time.timeZone = "Europe/Berlin";

    networking.hostName = "loki";

    system.stateVersion = "26.05";
  };
}
