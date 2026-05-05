{
  flake.modules.nixos.networkd = {
    hardware.facter.detected.dhcp.enable = false;
    networking.dhcpcd.enable = false;

    systemd.network = {
      enable = true;

      networks."10-dhcp" = {
        matchConfig.Type = "ether";
        networkConfig.DHCP = "yes";
      };
    };
  };
}
