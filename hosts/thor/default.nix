{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix

    ../../modules/users/tom

    ../../modules/optional/wireless.nix
  ];

  disko = {
    systemDevice = "/dev/nvme0n1";
    layout = "btrfs-luks";
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
