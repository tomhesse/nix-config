{
  flake.modules.nixos.restic-server =
    { config, pkgs, ... }:
    {
      users = {
        groups.restic = { };

        users.restic = {
          isSystemUser = true;
          group = "restic";
          home = "/var/lib/restic";
          createHome = true;
          shell = "${pkgs.bash}/bin/bash";
          openssh.authorizedKeys.keys = [
            (builtins.readFile ./hosts/loki/ssh_host_ed25519_key.pub)
            (builtins.readFile ./hosts/tyr/ssh_host_ed25519_key.pub)
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "d /srv/backups/restic/hosts/loki 0700 restic restic -"
        "d /srv/backups/restic/hosts/tyr 0700 restic restic -"
      ];

      services.restic.backups.restic-offsite = {
        repository = "sftp:u591202-sub1@u591202-sub1.your-storagebox.de:restic";
        passwordFile = config.sops.secrets."services/restic/offsite-password".path;
        initialize = true;

        paths = [
          "/srv/backups/restic"
          "/srv/media/music"
        ];

        extraOptions = [
          "sftp.command='ssh u591202-sub1@u591202-sub1.your-storagebox.de -i /persistent/etc/ssh/ssh_host_ed25519_key -p 23 -s sftp'"
        ];

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

      services.restic.backups.restic-local = {
        repository = "/srv/backups/restic/services";
        passwordFile = config.sops.secrets."services/restic/local-password".path;
        initialize = true;

        paths = [
          "/var/lib/grocy"
          "/var/lib/kanidm"
          "/var/lib/navidrome"
          "/var/lib/paperless"
          "/var/lib/private/prowlarr"
          "/var/lib/private/radarr"
          "/var/lib/postgresql"
        ];

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };

      sops.secrets."services/restic/local-password" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
      };

      sops.secrets."services/restic/offsite-password" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
      };

      environment.persistence."/persistent".directories = [
        {
          directory = "/var/lib/restic";
          user = "restic";
          group = "restic";
        }
      ];
    };
}
