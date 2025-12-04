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
    enable = lib.mkEnableOption "Enable declarative partition layout.";
    systemDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/dev/nvme0n1";
      apply =
        value:
        if value == null then
          null
        else if lib.hasPrefix "/dev/" value then
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

  config = lib.mkIf cfg.disko.enable (
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
          assertion = cfg.disko.systemDevice != null;
          message = "hostSpec.disko.systemDevice must be set when disko is enabled.";
        }
      ]
      ++ lib.optionals (cfg.disko.systemDevice != null) [
        {
          assertion = lib.hasPrefix "/dev/" cfg.disko.systemDevice;
          message = "hostSpec.disko.systemDevice must be an absolute /dev/* path when disko is enabled.";
        }
      ];
      disko.devices = layoutConfig;
    }
  );
}
