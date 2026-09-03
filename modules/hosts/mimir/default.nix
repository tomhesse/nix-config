{ self, ... }:
{
  configurations.nixos.mimir.module =
    { lib, pkgs, ... }:
    {
      imports = [
        self.diskoConfigurations.mimir
        self.modules.nixos.common-cpu-intel
        self.modules.nixos.common-pc-ssd
        self.modules.nixos.grub
        self.modules.nixos.server
        self.modules.nixos.smartd
        self.modules.nixos.user-thesse
        self.modules.nixos.zfs
      ];

      users.users.thesse.shell = lib.mkForce pkgs.bash;

      home-manager.users.thesse.imports = [
        self.modules.homeManager.server
      ];

      boot = {
        kernelParams = [ "zfs.zfs_arc_max=${toString (32 * 1024 * 1024 * 1024)}" ];

        loader.grub.mirroredBoots = [
          {
            path = "/boot1";
            devices = [ "nodev" ];
          }
          {
            path = "/boot2";
            devices = [ "nodev" ];
          }
        ];

        zfs.extraPools = [
          "scratch"
          "tank"
        ];
      };

      hardware.facter.reportPath = ./facter.json;

      disko.zfs.enable = true;

      environment.persistence."/persistent".enable = false;

      networking.hostId = "700e144e";
      networking.hostName = "mimir";

      system.stateVersion = "26.05";

      time.timeZone = "Europe/Berlin";
    };
}
