{ self, ... }:
{
  flake.modules.nixos.restic =
    { config, lib, ... }:
    let
      hostname = config.networking.hostName;
      hostKey = (builtins.head config.services.openssh.hostKeys).path;

      user = config.restic.offsite.user;
      target = "${user}@${user}.your-storagebox.de";
    in
    {
      imports = [ self.modules.nixos.notify-failure ];

      options.restic.offsite.user = lib.mkOption {
        type = lib.types.str;
        description = "Hetzner Storage Box sub-account holding this host's offsite repository.";
      };

      config = {
        programs.ssh.knownHosts."[${user}.your-storagebox.de]:23".publicKey =
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";

        services.restic.backups = {
          persistent = {
            repository = "sftp:restic-${hostname}@mimir.shrimphouse.xyz:/srv/backups/restic/${hostname}";
            passwordFile = config.sops.secrets."services/restic/password".path;
            initialize = true;

            paths = [ "/persistent" ];

            extraOptions = [
              "sftp.command='ssh restic-${hostname}@mimir.shrimphouse.xyz -i ${hostKey} -s sftp'"
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

          offsite = {
            repository = "sftp:${target}:persistent";
            passwordFile = config.sops.secrets."services/restic/offsite-password".path;
            initialize = true;
            runCheck = true;

            inherit (config.services.restic.backups.persistent) paths exclude;

            extraOptions = [ "sftp.command='ssh ${target} -i ${hostKey} -p 23 -s sftp'" ];

            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 4"
              "--keep-monthly 12"
              "--keep-yearly 2"
            ];

            timerConfig = {
              OnCalendar = lib.mkDefault "21:00";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
          };
        };

        systemd.services = {
          restic-backups-persistent.onFailure = [ "notify-failure@%N.service" ];
          restic-backups-offsite.onFailure = [ "notify-failure@%N.service" ];
        };

        sops.secrets = {
          "services/restic/password".sopsFile = ./hosts/${hostname}/secrets/nixos.yaml;
          "services/restic/offsite-password".sopsFile = ./hosts/${hostname}/secrets/nixos.yaml;
        };
      };
    };
}
