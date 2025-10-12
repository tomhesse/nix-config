{
  config,
  inputs,
  lib,
  ...
}:
let
  btrfs = import ./profiles/btrfs.nix;
  btrfsLuks = import ./profiles/btrfs-luks.nix;
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options.disko = {
    systemDevice = lib.mkOption {
      type = lib.types.str;
      example = "/dev/nvme0n1";
      apply =
        value:
        if lib.hasPrefix "/dev/" value then
          value
        else
          throw "Invalid device path: ${value}. Must start with /dev/";
      description = "System disk device (/dev/*)";
    };

    layout = lib.mkOption {
      type = lib.types.enum [
        "btrfs"
        "btrfs-luks"
      ];
      default = "btrfs";
      description = "Filesystem layout to use.";
    };
  };

  config =
    let
      layoutConfig =
        if config.disko.layout == "btrfs" then
          btrfs {
            disk = config.disko.systemDevice;
            inherit (config.networking) hostName;
          }
        else if config.disko.layout == "btrfs-luks" then
          btrfsLuks {
            disk = config.disko.systemDevice;
            inherit (config.networking) hostName;
          }
        else
          throw "Unsupported layout: ${config.disko.layout}";
    in
    {
      assertions = [
        {
          assertion = lib.hasPrefix "/dev/" config.disko.systemDevice;
          message = "disko.systemDevice must be a /dev/* device.";
        }
      ];
      disko.devices = layoutConfig;
    };
}
