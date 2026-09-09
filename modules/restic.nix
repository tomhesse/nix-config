{
  flake.modules.nixos.restic =
    { config, ... }:
    let
      hostname = config.networking.hostName;
      hostKey = (builtins.head config.services.openssh.hostKeys).path;
    in
    {
      services.restic.backups.persistent = {
        repository = "sftp:restic@mimir.shrimphouse.xyz:/srv/backups/restic/${hostname}";
        passwordFile = config.sops.secrets."services/restic/password".path;
        initialize = true;

        paths = [ "/persistent" ];

        extraOptions = [
          "sftp.command='ssh restic@mimir.shrimphouse.xyz -i ${hostKey} -s sftp'"
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
