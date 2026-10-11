{
  configurations.nixos.tyr.module =
    { pkgs, ... }:
    {
      home-manager.users.thesse.wallpaper = pkgs.fetchurl {
        url = "https://w.wallhaven.cc/full/ly/wallhaven-lyqjly.png";
        sha256 = "sha256-/X64eC0yvoIq92ib084qpR5T/CDYl+EFMdFd/cjDRSk=";
      };

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
    };
}
