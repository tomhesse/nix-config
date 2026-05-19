{
  flake.modules.nixos.node-exporter = {
    services.prometheus.exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      enabledCollectors = [
        "interrupts"
        "processes"
        "systemd"
        "tcpstat"
      ];
    };
  };
}
