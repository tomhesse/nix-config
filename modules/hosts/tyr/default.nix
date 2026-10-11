{ self, ... }:
{
  configurations.nixos.tyr.module = {
    imports = [
      self.diskoConfigurations.tyr
      self.modules.nixos.common-cpu-intel
      self.modules.nixos.common-gpu-nvidia-nonprime
      self.modules.nixos.common-pc-ssd
      self.modules.nixos.desktop
      self.modules.nixos.impermanence
      self.modules.nixos.nfs-client
      self.modules.nixos.restic
      self.modules.nixos.secure-boot
      self.modules.nixos.tang
      self.modules.nixos.user-thesse
    ];

    home-manager.users.thesse.imports = [
      self.modules.homeManager.abcde
      self.modules.homeManager.beets
      self.modules.homeManager.desktop
      self.modules.homeManager.osu
      self.modules.homeManager.prismlauncher
    ];

    hardware.nvidia = {
      open = false;
      branch = "legacy_580";
    };

    hardware.facter.reportPath = ./facter.json;

    time.timeZone = "Europe/Berlin";

    networking.hostName = "tyr";

    system.stateVersion = "26.05";
  };
}
