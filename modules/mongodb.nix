{
  flake.modules.nixos.mongodb =
    { pkgs, ... }:
    {
      services.mongodb = {
        enable = true;
        package = pkgs.mongodb-ce;
      };

      systemd.tmpfiles.rules = [
        "d /var/db/mongodb 0700 mongodb mongodb -"
      ];
    };
}
