{ self, ... }:
{
  configurations.nixos.tyr.module = {
    imports = [
      self.diskoConfigurations.tyr
      self.modules.nixos.common-cpu-intel
      self.modules.nixos.common-gpu-nvidia-nonprime
      self.modules.nixos.common-pc-ssd
      self.modules.nixos.desktop
      self.modules.nixos.nfs-client
      self.modules.nixos.secure-boot
      self.modules.nixos.tang
      self.modules.nixos.user-thesse
    ];

    home-manager.users.thesse = {
      imports = [
        self.modules.homeManager.abcde
        self.modules.homeManager.beets
        self.modules.homeManager.desktop
        self.modules.homeManager.osu
      ];

      wallpaper = builtins.fetchurl {
        url = "https://w.wallhaven.cc/full/ly/wallhaven-lyqjly.png";
        sha256 = "sha256-/X64eC0yvoIq92ib084qpR5T/CDYl+EFMdFd/cjDRSk=";
      };
    };

    hardware.nvidia.open = false;

    hardware.facter.reportPath = ./facter.json;

    monitors = {
      DP-1 = {
        description = "ASUSTek COMPUTER INC VG27AQL1A R5LMQS197620";
        resolution = "2560x1440";
        refreshRate = 144;
        position.x = 0;
        position.y = 0;
        primary = true;
        workspaces = [
          1
          2
          3
        ];
        defaultWorkspace = 1;
      };
      DP-2 = {
        description = "AOC 2490W1 APGL89A001738";
        resolution = "1920x1080";
        refreshRate = 60;
        position.x = 2560;
        position.y = 320;
        workspaces = [ 4 ];
        defaultWorkspace = 4;
      };
      HDMI-A-1 = {
        description = "AOC 2490W1 APGL89A001447";
        resolution = "1920x1080";
        refreshRate = 60;
        position.x = -1080;
        position.y = -240;
        rotation = "90";
        workspaces = [ 5 ];
        defaultWorkspace = 5;
      };
    };

    fileSystems."/mnt/music" = {
      device = "mimir:/media/music";
      fsType = "nfs4";
      options = [
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
      ];
    };

    time.timeZone = "Europe/Berlin";

    networking.hostName = "tyr";

    system.stateVersion = "25.11";
  };
}
