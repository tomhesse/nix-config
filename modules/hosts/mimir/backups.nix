{
  configurations.nixos.mimir.module =
    { config, pkgs, ... }:
    let
      target = "u591202-sub1@u591202-sub1.your-storagebox.de";
      hostKey = (builtins.head config.services.openssh.hostKeys).path;
    in
    {
      services = {
        nfs.server.exports = ''
          /srv/backups/homeassistant 10.0.20.20(rw,sync,no_subtree_check,all_squash,anonuid=431,anongid=431)
        '';

        restic.backups = {
          offsite-homeassistant = {
            repository = "sftp:${target}:homeassistant";
            passwordFile = config.sops.secrets."services/restic/offsite-password".path;
            initialize = true;

            paths = [ "/srv/backups/homeassistant" ];

            extraOptions = [ "sftp.command='ssh ${target} -i ${hostKey} -p 23 -s sftp'" ];

            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 4"
              "--keep-monthly 12"
              "--keep-yearly 2"
            ];

            timerConfig = {
              OnCalendar = "06:30";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
          };

          offsite-music = {
            repository = "sftp:${target}:music";
            passwordFile = config.sops.secrets."services/restic/offsite-password".path;
            initialize = true;

            paths = [ "/srv/media/music" ];

            extraOptions = [ "sftp.command='ssh ${target} -i ${hostKey} -p 23 -s sftp'" ];

            pruneOpts = [
              "--keep-weekly 8"
              "--keep-monthly 12"
              "--keep-yearly 2"
            ];

            timerConfig = {
              OnCalendar = "Sun 02:00";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
          };

          offsite-services =
            let
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

          "tank/archive" = {
            useTemplate = [ "archive" ];
            recursive = true;
          };

          "rpool/services" = {
            useTemplate = [ "services" ];
            recursive = true;
          };

          "tank/backups/homeassistant".useTemplate = [ "homeassistant" ];

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
          recvOptions = "u o compression=zstd";
        };
      };

      users = {
        groups = {
          homeassistant.gid = 431;
          macmini.gid = 430;
          restic-loki.gid = 420;
          restic-tyr.gid = 421;
        };

        users = {
          homeassistant = {
            isSystemUser = true;
            group = "homeassistant";
            uid = 431;
          };

          macmini = {
            isSystemUser = true;
            group = "macmini";
            uid = 430;
          };

          restic-loki = {
            isSystemUser = true;
            group = "restic-loki";
            uid = 420;
            home = "/srv/backups/restic/loki";
            shell = "${pkgs.bash}/bin/bash";
            openssh.authorizedKeys.keys = [
              "restrict ${builtins.readFile ../loki/ssh_host_ed25519_key.pub}"
            ];
          };

          restic-tyr = {
            isSystemUser = true;
            group = "restic-tyr";
            uid = 421;
            home = "/srv/backups/restic/tyr";
            shell = "${pkgs.bash}/bin/bash";
            openssh.authorizedKeys.keys = [
              "restrict ${builtins.readFile ../tyr/ssh_host_ed25519_key.pub}"
            ];
          };
        };
      };

      systemd = {
        tmpfiles.rules = [
          "z /srv/backups/homeassistant 0700 homeassistant homeassistant -"
          "z /srv/backups/restic/loki 0700 restic-loki restic-loki -"
          "z /srv/backups/restic/tyr 0700 restic-tyr restic-tyr -"
          "z /srv/backups/timemachine/macmini 0700 macmini macmini -"
        ];

        services = {
          restic-backups-offsite-homeassistant.onFailure = [ "notify-failure@%N.service" ];

          restic-backups-offsite-music.onFailure = [ "notify-failure@%N.service" ];

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

      system.activationScripts.preUpgradeSnapshot = ''
        if [ ! -e /run/current-system ] || [ "$(readlink -f /run/current-system)" != "$systemConfig" ]; then
          if [ -e /run/booted-system ]; then
            zfs=/run/booted-system/sw/bin/zfs
          else
            zfs="$systemConfig/sw/bin/zfs"
          fi

          "$zfs" snapshot -r "rpool/services@pre-upgrade-$(date +%F-%H%M%S)"

          "$zfs" list -H -d 1 -o name -t snapshot -s creation rpool/services \
            | grep '@pre-upgrade-' \
            | head -n -5 \
            | while read -r snap; do "$zfs" destroy -r "$snap"; done
        fi
      '';

      sops.secrets = {
        "services/restic/offsite-password".sopsFile = ./secrets/nixos.yaml;
        "services/samba/macmini/password".sopsFile = ./secrets/nixos.yaml;
      };
    };
}
