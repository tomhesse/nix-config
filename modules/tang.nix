{
  flake.modules.nixos.tang = {
    services.tang = {
      enable = true;
      ipAddressAllow = [ "10.0.20.0/24" ];
    };

    environment.persistence."/persistent" = {
      directories = [ "/var/lib/private/tang" ];
    };
  };
}
