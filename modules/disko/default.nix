{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.hostSpec;

  btrfs = import ./profiles/btrfs.nix;
  btrfsLuks = import ./profiles/btrfs-luks.nix;
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options.hostSpec.disko = {
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
        if cfg.disko.layout == "btrfs" then
          btrfs {
            inherit lib;
            inherit (cfg) hostName;
            disk = cfg.disko.systemDevice;
            enablePersist = cfg.impermanence.enable or true;
          }
        else if cfg.disko.layout == "btrfs-luks" then
          btrfsLuks {
            inherit lib;
            inherit (cfg) hostName;
            disk = cfg.disko.systemDevice;
            enablePersist = cfg.impermanence.enable or true;
          }
        else
          throw "Unsupported layout: ${cfg.disko.layout}";
    in
    {
      assertions = [
        {
          assertion = lib.hasPrefix "/dev/" cfg.disko.systemDevice;
          message = "disko.systemDevice must be a /dev/* device.";
        }
      ];
      disko.devices = layoutConfig;
    };
}
