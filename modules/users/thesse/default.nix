{
  flake.modules.nixos.user-thesse =
    { config, pkgs, ... }:
    {
      sops.secrets."users/thesse/password".neededForUsers = true;
      sops.secrets."users/thesse/age-key".owner = "thesse";

      users.users.thesse = {
        isNormalUser = true;
        uid = 1000;
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."users/thesse/password".path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keyFiles = [ ./ssh.pub ];
      };

    };
}
