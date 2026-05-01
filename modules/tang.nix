{
  flake.modules.nixos.tang =
    { config, lib, ... }:
    let
      inherit (builtins) match elemAt;
      extractPort =
        s:
        let
          m = match ".*[:\\]]([0-9]+)" s;
        in
        if m != null then lib.toInt (elemAt m 0) else lib.toInt s;
    in
    {
      services.tang = {
        enable = true;
        ipAddressAllow = [
          "10.0.10.0/24"
          "10.0.20.0/24"
        ];
      };

      networking.firewall.allowedTCPPorts = map extractPort config.services.tang.listenStream;

      environment.persistence."/persistent" = {
        directories = [ "/var/lib/private/tang" ];
      };
    };
}
