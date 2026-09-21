{ self, config, ... }:
{
  perSystem.packages.installer-iso =
    config.flake.nixosConfigurations.installer.config.system.build.isoImage;

  configurations.nixos.installer.module =
    {
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        self.modules.nixos.locale
        self.modules.nixos.nix
        self.modules.nixos.time
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      boot.zfs.forceImportRoot = false;

      image.baseName = lib.mkForce "nixos-installer";

      users.users.nixos.openssh.authorizedKeys.keyFiles = [ ../../users/thesse/ssh.pub ];

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
      systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

      system.stateVersion = "26.05";
    };
}
