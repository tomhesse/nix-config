{
  flake.modules.nixos.systemd-exporter = {
    services.prometheus.exporters.systemd = {
      enable = true;
      listenAddress = "127.0.0.1";
    };
  };
}
