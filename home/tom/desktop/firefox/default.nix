{ config, lib, ... }:
{
  imports = lib.mapAttrsToList (name: _: ./. + "/${name}") (
    lib.filterAttrs (
      name: type:
      (type == "directory" || (lib.hasSuffix ".nix" name && name != "default.nix"))
      && !(lib.hasPrefix "." name)
    ) (builtins.readDir ./.)
  );

  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      ".mozilla/firefox"
    ];
  };

  programs.firefox = {
    enable = true;
    languagePacks = [ "en-US" ];
  };
}
