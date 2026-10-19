{
  configurations.nixos.loki.module =
    { config, ... }:
    {
      sops.secrets = {
        "services/wireguard/shrimphouse-vpn-01".sopsFile = ./secrets/nixos.yaml;
        "services/wireguard/shrimphouse-vpn-01-psk".sopsFile = ./secrets/nixos.yaml;
      };

      sops.templates.networkmanager.content = ''
        WG_PRIVATE_KEY=${config.sops.placeholder."services/wireguard/shrimphouse-vpn-01"}
        WG_PRESHARED_KEY=${config.sops.placeholder."services/wireguard/shrimphouse-vpn-01-psk"}
      '';

      networking.networkmanager.ensureProfiles.profiles.shrimphouse-vpn-01 = {
        connection = {
          id = "shrimphouse-vpn-01";
          type = "wireguard";
          interface-name = "wg-shrimphouse";
          autoconnect = false;
        };
        wireguard.private-key = "$WG_PRIVATE_KEY";
        "wireguard-peer.a1xOn1vRabwYWJyxoBIt9kmJ9uASUyHOKp4K3H9xGw4=" = {
          endpoint = "vpn.shrimphouse.xyz:51820";
          allowed-ips = "10.0.20.0/24;10.0.200.1/32;";
          preshared-key = "$WG_PRESHARED_KEY";
          preshared-key-flags = 0;
        };
        ipv4 = {
          method = "manual";
          address1 = "10.0.200.4/32";
          dns = "10.0.200.1;";
          dns-search = "shrimphouse.xyz;";
        };
        ipv6.method = "disabled";
      };
    };
}
