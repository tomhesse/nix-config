{
  flake.modules.nixos.clevis = {
    boot.initrd = {
      clevisLuksAskpass = {
        enable = true;
        useTang = true;
      };

      systemd.network = {
        enable = true;
        networks."10-dhcp" = {
          matchConfig.Type = "ether";
          networkConfig.DHCP = "yes";
        };
      };
    };
  };
}
