{
  flake.modules.nixos.smartctl-exporter = {
    services.prometheus.exporters.smartctl = {
      enable = true;
      listenAddress = "127.0.0.1";
    };
  };
}
