{
  flake.modules.nixos.exportarr-prowlarr =
    { config, ... }:
    {
      services.prometheus.exporters.exportarr-prowlarr = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9710;
        url = "http://127.0.0.1:9696";
        apiKeyFile = config.sops.secrets."services/exportarr/prowlarr-api-key".path;
      };

      sops.secrets."services/exportarr/prowlarr-api-key".sopsFile =
        ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
    };
}
