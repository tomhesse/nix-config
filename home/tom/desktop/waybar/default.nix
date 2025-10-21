{ lib, ... }:
{
  imports = lib.mapAttrsToList (name: _: ./. + "/${name}") (
    lib.filterAttrs (
      name: type:
      (type == "directory" || (lib.hasSuffix ".nix" name && name != "default.nix"))
      && !(lib.hasPrefix "." name)
    ) (builtins.readDir ./.)
  );

  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };
}
