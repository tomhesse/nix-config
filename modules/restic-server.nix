{
  flake.modules.nixos.restic-server =
    { pkgs, ... }:
    let
      clients = [
        "loki"
        "tyr"
      ];
    in
    {
      users = {
        groups.restic.gid = 420;

        users.restic = {
          isSystemUser = true;
          group = "restic";
          uid = 420;
          home = "/srv/backups/restic";
          shell = "${pkgs.bash}/bin/bash";
          openssh.authorizedKeys.keys = map (
            host: "restrict ${builtins.readFile ./hosts/${host}/ssh_host_ed25519_key.pub}"
          ) clients;
        };
      };

      systemd.tmpfiles.rules = map (host: "z /srv/backups/restic/${host} 0700 restic restic -") clients;
    };
}
