{
  flake.modules.nixos.user-thesse =
    { config, pkgs, ... }:
    {
      sops.secrets."users/thesse/password".neededForUsers = true;
      sops.secrets."users/thesse/age-key".owner = "thesse";

      users.users.thesse = {
        isNormalUser = true;
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."users/thesse/password".path;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keyFiles = [
          (pkgs.fetchurl {
            url = "https://codeberg.org/tomhesse.keys";
            name = "tomhesse-authorized-keys";
            hash = "sha256-qJO8bEW8fdtOSaWmu7BoYxNDUv8x1dA5rH/B2D2UEDk=";
          })
        ];
      };

    };
}
