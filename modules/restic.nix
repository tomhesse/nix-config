{
  flake.modules.nixos.restic =
    { config, ... }:
    let
      hostname = config.networking.hostName;
    in
    {
      services.restic.backups.persistent = {
        repository = "sftp:restic@mimir.shrimphouse.xyz:/srv/backups/restic/hosts/${hostname}";
        passwordFile = config.sops.secrets."services/restic/password".path;
        initialize = true;

        paths = [ "/persistent" ];

        extraOptions = [
          "sftp.command='ssh restic@mimir.shrimphouse.xyz -i /persistent/etc/ssh/ssh_host_ed25519_key -s sftp'"
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

      sops.secrets."services/restic/password" = {
        sopsFile = ./hosts/${hostname}/secrets/nixos.yaml;
      };
    };
}
