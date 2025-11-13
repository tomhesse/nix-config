{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostSpec) hostName;
  inherit (lib) mkIf optional pathExists;

  enabled = config.hostSpec.users.tom.enable or false;

  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  sshKeys = lib.splitString "\n" (
    builtins.readFile (
      builtins.fetchurl {
        url = "https://github.com/tomhesse.keys";
        sha256 = "0f8hjhyxihbzmhwx1m9izx9464v3d2qbp9m5957dnzdw8mnbr4x8";
      }
    )
  );

  hostModulePath = ../../home/tom/hosts + "/${hostName}";
  hostModule = optional (pathExists hostModulePath) hostModulePath;
in
{
  config = mkIf enabled {
    sops.secrets = {
      "users/tom/password" = {
        neededForUsers = true;
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

    home-manager.users.tom = {
      imports = [
        ../../../home/tom/core
      ]
      ++ hostModule;
    };
  };
}
