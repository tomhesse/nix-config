{ self, config, ... }:
{
  perSystem.packages.installer-iso =
    config.flake.nixosConfigurations.installer.config.system.build.isoImage;

  configurations.nixos.installer.module =
    { pkgs, modulesPath, ... }:
    {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        self.modules.nixos.locale
        self.modules.nixos.nix
        self.modules.nixos.time
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      users.users.nixos.openssh.authorizedKeys.keyFiles = [
        (pkgs.fetchurl {
          url = "https://codeberg.org/tomhesse.keys";
          hash = "sha256-qJO8bEW8fdtOSaWmu7BoYxNDUv8x1dA5rH/B2D2UEDk=";
        })
      ];

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
      systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

      system.stateVersion = "25.11";
    };
}
