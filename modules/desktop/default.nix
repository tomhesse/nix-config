{ lib, ... }:
let
  inherit (lib)
    filterAttrs
    hasPrefix
    hasSuffix
    mapAttrsToList
    mkEnableOption
    ;
in
{
  imports = mapAttrsToList (name: _: ./. + "/${name}") (
    filterAttrs (
      name: type:
      (type == "directory" || (hasSuffix ".nix" name && name != "default.nix")) && !(hasPrefix "." name)
    ) (builtins.readDir ./.)
  );

  options.hostSpec.desktop.enable = mkEnableOption "Enable desktop environment on this system.";
}
