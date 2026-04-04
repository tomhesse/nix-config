{ self, ... }:
{
  flake.modules.nixos.user-thesse =
    { config, pkgs, ... }:
    {
      sops.secrets."users/thesse/password".neededForUsers = true;

      users.users.thesse = {
        isNormalUser = true;
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."users/thesse/password".path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keyFiles = [ ./thesse.pub ];
      };

      home-manager.users.thesse = {
        imports = [ self.modules.homeManager.base ];
      };
    };
}
