{
  configurations.nixos.mimir.module =
    { config, ... }:
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

      systemd.services.restic-backups-offsite-services = {
        path = [ config.boot.zfs.package ];
        onFailure = [ "notify-failure@%N.service" ];
      };

      sops.secrets."services/restic/offsite-password".sopsFile = ./secrets/nixos.yaml;
    };
}
