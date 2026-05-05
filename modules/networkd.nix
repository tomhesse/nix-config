{
  flake.modules.nixos.networkd = {
    networking.useNetworkd = true;

    systemd.network = {
      enable = true;

      networks."10-dhcp" = {
        matchConfig.Type = "ether";
        networkConfig.DHCP = "yes";
      };
    };
  };
}
