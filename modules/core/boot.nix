{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.hostSpec.boot;

  diskoLayout = config.hostSpec.disko.layout;

  impermanenceEnabled = config.hostSpec.impermanence.enable;

  diskDevices = lib.attrsToList (config.disko.devices.disk or { });

  luksPartitions = lib.concatMap (
    disk:
    let
      diskName = disk.name;
      diskConfig = disk.value;
      partitions = diskConfig.content.partitions or { };
    in
    lib.mapAttrsToList (
      partName: partConfig:
      let
        partitionType = partConfig.content.type or "";
      in
      {
        inherit diskName partName partitionType;
      }
    ) partitions
  ) diskDevices;

  luksPartition = lib.findFirst (partition: partition.partitionType == "luks") null luksPartitions;

  luksDevice =
    if luksPartition == null then
      null
    else
      "/dev/disk/by-partlabel/disk-${luksPartition.diskName}-${luksPartition.partName}";

  cryptenroll = pkgs.writeShellApplication {
    name = "cryptenroll";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      device=${luksDevice}

      if [ -z "''${device}" ]; then
        echo "cryptenroll: no LUKS partition found in disko config" >&2;
        exit 1
      fi

      exec systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,2,7 "''${device}" "$@"
    '';
  };
in
{
  options.hostSpec.boot.secureBoot.enable =
    mkEnableOption "Enable secure boot on the host (requires enrolled and created keys).";

  config = {
    boot = {
      loader = {
        limine = {
          enable = true;
          enableEditor = false;
          maxGenerations = 10;
          secureBoot.enable = cfg.secureBoot.enable;
        };
        efi.canTouchEfiVariables = true;
      };
      initrd.systemd.enable = true;
    };

    environment.systemPackages = mkIf (diskoLayout == "btrfs-luks" && cfg.secureBoot.enable) [
      cryptenroll
    ];

    environment.persistence = mkIf (impermanenceEnabled && cfg.secureBoot.enable) {
      "/persist".directories = [
        "/var/lib/sbctl"
      ];
    };
  };
}
