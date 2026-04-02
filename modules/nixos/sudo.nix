{
  flake.modules.nixos.sudo =
    { config, lib, ... }:
    {
      security.sudo = {
        enable = true;
        execWheelOnly = true;
      };

      environment.persistence = lib.mkIf config.hostSpec.impermanence.enable {
        "/persistent".directories = [
          "/var/db/sudo/lectured"
        ];
      };
    };
}
