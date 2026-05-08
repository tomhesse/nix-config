{
  flake.modules.nixos.restic-server =
    { pkgs, ... }:
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
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "d /srv/backups/restic/loki 0700 restic restic -"
      ];

      environment.persistence."/persistent".directories = [
        {
          directory = "/var/lib/restic";
          user = "restic";
          group = "restic";
        }
      ];
    };
}
