{
  flake.modules.nixos.blackbox-exporter =
    { pkgs, ... }:
    {
      services.prometheus.exporters.blackbox = {
        enable = true;
        listenAddress = "127.0.0.1";
        configFile = (pkgs.formats.yaml { }).generate "blackbox.yml" {
          modules = {
            http_ssl = {
              prober = "http";
              http = {
                fail_if_not_ssl = true;
                valid_status_codes = [ ];
              };
            };
            ldaps_connect = {
              prober = "tcp";
              tcp = {
                tls = true;
                tls_config.server_name = "idm.shrimphouse.xyz";
              };
            };
          };
        };
      };
    };
}
