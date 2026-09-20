{ self, ... }:
{
  configurations.nixos.loki.module =
    { pkgs, ... }:
    {
      imports = [
        self.diskoConfigurations.loki
        self.modules.nixos.desktop
        self.modules.nixos.framework-13-7040-amd
        self.modules.nixos.impermanence
        self.modules.nixos.nfs-client
        self.modules.nixos.restic
        self.modules.nixos.secure-boot
        self.modules.nixos.user-thesse
      ];

      home-manager.users.thesse = {
        imports = [ self.modules.homeManager.desktop ];

        wallpaper = pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/k8/wallhaven-k899o7.png";
          sha256 = "sha256-36sgTh1D/8KQlLhx/ZfhwFyoXfO59JoOBZnJFPjligM=";
        };
      };

      restic.offsite.user = "u591202-sub3";

      hardware.facter.reportPath = ./facter.json;

      monitors = {
        eDP-1 = {
          resolution = "2880x1920";
          refreshRate = 120;
          scale = 2;
          primary = true;
        };
      };

      fileSystems."/mnt/music" = {
        device = "mimir.shrimphouse.xyz:/srv/media/music";
        fsType = "nfs4";
        options = [
          "noauto"
          "ro"
          "x-systemd.automount"
          "x-systemd.idle-timeout=600"
        ];
      };

      time.timeZone = "Europe/Berlin";

      networking.hostName = "loki";

      system.stateVersion = "26.05";
    };
}
