{
  flake.modules.nixos.restic-server =
    { lib, pkgs, ... }:
    let
      clients = {
        loki = 420;
        tyr = 421;
      };
    in
    {
      users = {
        groups = lib.mapAttrs' (host: id: lib.nameValuePair "restic-${host}" { gid = id; }) clients;

        users = lib.mapAttrs' (
          host: id:
          lib.nameValuePair "restic-${host}" {
            isSystemUser = true;
            group = "restic-${host}";
            uid = id;
            home = "/srv/backups/restic/${host}";
            shell = "${pkgs.bash}/bin/bash";
            openssh.authorizedKeys.keys = [
              "restrict ${builtins.readFile ./hosts/${host}/ssh_host_ed25519_key.pub}"
            ];
          }
        ) clients;
      };

      systemd.tmpfiles.rules = lib.mapAttrsToList (
        host: _: "z /srv/backups/restic/${host} 0700 restic-${host} restic-${host} -"
      ) clients;
    };
}
