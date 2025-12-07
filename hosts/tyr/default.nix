{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
  ];

  hardware.nvidia.open = false;

  hostSpec = {
    allowedUnfree = [
      "nvidia-settings"
      "nvidia-x11"
    ];
    boot.secureBoot.enable = false;
    desktop = {
      enable = true;
      wifi.enable = true;
      window-manager.hyprland.enable = true;
    };
    disko = {
      enable = true;
      systemDevice = "/dev/nvme0n1";
      layout = "btrfs-luks";
    };
    impermanence.enable = true;
    shells.fish.enable = true;
    theme.catppuccin = {
      enable = true;
    };
    timeZone = "Europe/Berlin";
    users = {
      tom.enable = true;
    };
    zram.enable = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
