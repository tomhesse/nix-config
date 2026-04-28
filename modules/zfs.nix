{
  flake.modules.nixos.zfs = {
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;
  };
}
