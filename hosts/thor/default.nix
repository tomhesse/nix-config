{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
  ];

  hostSpec = {
    disko = {
      systemDevice = "/dev/nvme0n1";
      layout = "btrfs-luks";
    };
    impermanence.enable = true;
    shells.fish.enable = true;
    theme.catppuccin.enable = true;
    timeZone = "Europe/Berlin";
    users = {
      tom.enable = true;
    };
    zram.enable = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
