{
  flake.modules.nixos.networkd = {
    systemd.network.enable = true;
    networking.dhcpcd.enable = false;

    systemd.network.networks."10-dhcp" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
    };
  };
}
