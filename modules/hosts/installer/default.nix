{ self, ... }:
{
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
        ../../users/thesse/thesse.pub
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
