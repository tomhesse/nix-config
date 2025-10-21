{ lib, ... }:
{
  options.wallpaper = lib.mkOption {
    type = lib.types.path;
    description = "Path to wallpaper image.";
  };
}
