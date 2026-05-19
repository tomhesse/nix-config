{
  flake.modules.nixos.exportarr-bazarr =
    { config, ... }:
    {
      services.prometheus.exporters.exportarr-bazarr = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9711;
        url = "http://127.0.0.1:6767";
        apiKeyFile = config.sops.secrets."services/exportarr/bazarr-api-key".path;
      };

      sops.secrets."services/exportarr/bazarr-api-key".sopsFile =
        ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
    };
}
