{ self, ... }:
{
  configurations.nixos.tyr.module = {
    imports = [
      self.diskoConfigurations.tyr
      self.modules.nixos.common-cpu-intel
      self.modules.nixos.common-gpu-nvidia
      self.modules.nixos.common-pc-ssd
      self.modules.nixos.desktop
      self.modules.nixos.secure-boot
      self.modules.nixos.user-thesse
    ];

    home-manager.users.thesse.imports = [ self.modules.homeManager.desktop ];

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
      };
      DP-2 = {
        description = "AOC 2490W1 APGL89A001738";
        resolution = "1920x1080";
        refreshRate = 60;
        position.x = 2560;
        position.y = 320;
      };
      HDMI-A-1 = {
        description = "AOC 2490W1 APGL89A001447";
        resolution = "1920x1080";
        refreshRate = 60;
        position.x = -1080;
        position.y = -240;
        rotation = "90";
      };
    };

    time.timeZone = "Europe/Berlin";

    networking.hostName = "tyr";

    system.stateVersion = "25.11";
  };
}
