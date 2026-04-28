{
  flake.modules.nixos.clevis = {
    boot.initrd.clevis = {
      enable = true;
      useTang = true;
    };

    boot.initrd.systemd.network.enable = true;
  };
}
