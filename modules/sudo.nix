{
  flake.modules.nixos.sudo = {
    security.sudo = {
      enable = true;
      execWheelOnly = true;
    };

    environment.persistence."/persistent".directories = [
      "/var/db/sudo/lectured"
    ];
  };
}
