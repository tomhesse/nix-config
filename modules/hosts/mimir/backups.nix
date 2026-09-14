{
  configurations.nixos.mimir.module =
    { config, pkgs, ... }:
    {
      services = {
        restic.backups.offsite-services =
          let
            target = "u591202-sub1@u591202-sub1.your-storagebox.de";
            hostKey = (builtins.head config.services.openssh.hostKeys).path;
            syncoid = "syncoid-rpool-services";
          in
          {
            repository = "sftp:${target}:services";
            passwordFile = config.sops.secrets."services/restic/offsite-password".path;
            initialize = true;

            paths = [ "/srv/backups/services" ];

            extraOptions = [ "sftp.command='ssh ${target} -i ${hostKey} -p 23 -s sftp'" ];

            backupPrepareCommand = ''
              mounted=$(zfs list -H -o mounted -r tank/backups/services) || exit 1
              case "$mounted" in
                *no*)
                  echo "replica datasets are not mounted" >&2
                  exit 1
                  ;;
              esac
              systemctl stop ${syncoid}.timer ${syncoid}.service
            '';

            backupCleanupCommand = "systemctl start ${syncoid}.timer";

            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 4"
              "--keep-monthly 12"
              "--keep-yearly 2"
            ];

            timerConfig = {
              OnCalendar = "03:00";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
          };

        samba.settings.macmini = {
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

        sanoid.datasets = {
          "rpool/root".useTemplate = [ "system" ];

          "rpool/services" = {
            useTemplate = [ "services" ];
            recursive = true;
          };

          "tank/backups/restic" = {
            useTemplate = [ "restic" ];
            recursive = true;
          };

          "tank/backups/services" = {
            useTemplate = [ "replica" ];
            recursive = true;
          };

          "tank/backups/timemachine" = {
            useTemplate = [ "timemachine" ];
            recursive = true;
          };

          "tank/media" = {
            useTemplate = [ "media" ];
            recursive = true;
          };
        };

        syncoid.commands."rpool/services" = {
          target = "tank/backups/services";
          recursive = true;
          recvOptions = "u o compression=zstd o readonly=on";
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

        services = {
          restic-backups-offsite-services = {
            path = [ config.boot.zfs.package ];
            onFailure = [ "notify-failure@%N.service" ];
          };

          samba-macmini-password = {
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
      };

      sops.secrets = {
        "services/restic/offsite-password".sopsFile = ./secrets/nixos.yaml;
        "services/samba/macmini/password".sopsFile = ./secrets/nixos.yaml;
      };
    };
}
