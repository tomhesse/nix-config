{
  flake.modules.homeManager.wallpaper =
    { lib, pkgs, ... }:
    {
      options.wallpaper = lib.mkOption {
        type = lib.types.path;
        default = pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/x6/wallhaven-x6x3gz.png";
          sha256 = "sha256-Yvtnxaj32YXpUkXQKF1VNcApQf0v3JXGp9TNAsoJmbM=";
        };
        description = "Path to the wallpaper";
      };
    };
}
