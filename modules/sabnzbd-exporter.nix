{
  flake.modules.nixos.sabnzbd-exporter =
    { config, ... }:
    {
      services.prometheus.exporters.sabnzbd = {
        enable = true;
        listenAddress = "127.0.0.1";
        servers = [
          {
            baseUrl = "http://127.0.0.1:8080";
            apiKeyFile = config.sops.secrets."services/sabnzbd-exporter/sabnzbd-api-key".path;
          }
        ];
      };

      sops.secrets."services/sabnzbd-exporter/sabnzbd-api-key".sopsFile =
        ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
    };
}
