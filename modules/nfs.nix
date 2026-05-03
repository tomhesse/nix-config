{
  flake.modules.nixos.nfs-server = {
    services.nfs.server.enable = true;
    networking.firewall.allowedTCPPorts = [ 2049 ];
  };

  flake.modules.nixos.nfs-client = {
    boot.supportedFilesystems = [ "nfs" ];
  };
}
