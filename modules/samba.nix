{
  flake.modules.nixos.samba =
    { config, ... }:
    {
      services.samba = {
        enable = true;
        openFirewall = false;
        nmbd.enable = false;
        winbindd.enable = false;

        settings.global = {
          "server role" = "standalone server";
          "server string" = config.networking.hostName;
          "workgroup" = "WORKGROUP";
          "server min protocol" = "SMB2";
          "fruit:metadata" = "stream";
          "fruit:model" = "MacSamba";
          "fruit:nfs_aces" = "no";
          "fruit:posix_rename" = "yes";
        };
      };

      networking.firewall.allowedTCPPorts = [ 445 ];

      environment.persistence."/persistent".directories = [
        "/var/lib/samba"
      ];
    };
}
