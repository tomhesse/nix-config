{ lib, ... }:
let
  inherit (lib) mkOption types;

  defaultWallpaper = builtins.fetchurl {
    url = "https://w.wallhaven.cc/full/x6/wallhaven-x6x3gz.png";
    sha256 = "1cwr17505kfllz39bp1gzm0jkh1mamfjil25ablqbngpm32ngyv2";
  };
in
{
  options.homeSpec.wallpaper = mkOption {
    type = types.path;
    default = defaultWallpaper;
    description = "Path to the wallpaper used in this home-manager configuration";
  };
}
