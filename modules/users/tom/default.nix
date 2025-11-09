{
  config,
  lib,
  pkgs,
  ...
}:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  sshKeys = lib.splitString "\n" (
    builtins.readFile (
      builtins.fetchurl {
        url = "https://github.com/tomhesse.keys";
        sha256 = "0f8hjhyxihbzmhwx1m9izx9464v3d2qbp9m5957dnzdw8mnbr4x8";
      }
    )
  );
in
{
  sops.secrets = {
    "users/tom/password" = {
      neededForUsers = true;
    };
    "users/tom/age-key" = {
      owner = "${config.users.users.tom.name}";
      group = "${config.users.users.tom.group}";
    };
  };

  users.users.tom = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
      "wheel"
    ];
    hashedPasswordFile = config.sops.secrets."users/tom/password".path;
    openssh.authorizedKeys.keys = sshKeys;
  };

  home-manager.users.tom = import ../../../home/tom/hosts/${config.networking.hostName};

  security.pam.services.hyprlock = { };
}
