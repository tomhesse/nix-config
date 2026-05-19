{
  flake.modules.nixos.exportarr-sonarr =
    { config, ... }:
    {
      services.prometheus.exporters.exportarr-sonarr = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9709;
        url = "http://127.0.0.1:8989";
        apiKeyFile = config.sops.secrets."services/exportarr/sonarr-api-key".path;
      };

      sops.secrets."services/exportarr/sonarr-api-key".sopsFile =
        ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
    };
}
