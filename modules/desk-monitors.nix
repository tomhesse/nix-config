{
  flake.modules.nixos.desk-monitors = {
    monitors = {
      DP-1 = {
        description = "ASUSTek COMPUTER INC VG27AQL1A R5LMQS197620";
        resolution = "2560x1440";
        refreshRate = 144.006;
        position.x = 0;
        position.y = 0;
      };
      DP-2 = {
        description = "PNP(AOC) 2490W1 APGL89A001738";
        resolution = "1920x1080";
        refreshRate = 60;
        position.x = 2560;
        position.y = 180;
      };
      HDMI-A-1 = {
        description = "PNP(AOC) 2490W1 APGL89A001447";
        resolution = "1920x1080";
        refreshRate = 60;
        position.x = -1080;
        position.y = -240;
        rotation = "90";
      };
    };
  };
}
