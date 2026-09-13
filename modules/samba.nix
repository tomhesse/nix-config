{ self, ... }:
{
  flake.modules.nixos.samba =
    { config, pkgs, ... }:
    {
      imports = [ self.modules.nixos.notify-failure ];

      services.samba = {
        enable = true;
        openFirewall = false;
        nmbd.enable = false;
        winbindd.enable = false;

        settings = {
          global = {
            "server role" = "standalone server";
            "server string" = config.networking.hostName;
            "workgroup" = "WORKGROUP";
            "server min protocol" = "SMB2";
            "fruit:metadata" = "stream";
            "fruit:model" = "MacSamba";
            "fruit:nfs_aces" = "no";
            "fruit:posix_rename" = "yes";
          };

          macmini = {
            path = "/srv/backups/timemachine/macmini";
            "valid users" = "macmini";
            "force user" = "macmini";
            "force group" = "macmini";
            writable = "yes";
            browsable = "yes";
            "vfs objects" = "catia fruit streams_xattr";
            "fruit:time machine" = "yes";
            "fruit:time machine max size" = "1T";
          };
        };
      };

      users = {
        groups.macmini.gid = 430;

        users.macmini = {
          isSystemUser = true;
          group = "macmini";
          uid = 430;
        };
      };

      systemd = {
        tmpfiles.rules = [ "z /srv/backups/timemachine/macmini 0700 macmini macmini -" ];

        services.samba-macmini-password = {
          wantedBy = [ "multi-user.target" ];
          after = [ "samba-smbd.service" ];
          onFailure = [ "notify-failure@%N.service" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          script = ''
            pw=$(cat ${config.sops.secrets."services/samba/macmini/password".path})
            printf '%s\n%s\n' "$pw" "$pw" | ${pkgs.samba}/bin/smbpasswd -s -a macmini
          '';
        };
      };

      sops.secrets."services/samba/macmini/password" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
      };

      networking.firewall.allowedTCPPorts = [ 445 ];

      environment.persistence."/persistent".directories = [
        "/var/lib/samba"
      ];
    };
}
