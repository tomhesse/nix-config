{
  flake.modules.nixos.exportarr-radarr =
    { config, ... }:
    {
      services.prometheus.exporters.exportarr-radarr = {
        enable = true;
        listenAddress = "127.0.0.1";
        url = "http://127.0.0.1:7878";
        apiKeyFile = config.sops.secrets."services/exportarr/radarr-api-key".path;
      };

      sops.secrets."services/exportarr/radarr-api-key".sopsFile =
        ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
    };
}
