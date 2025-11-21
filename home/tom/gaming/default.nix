{ lib, ... }:
let
  inherit (lib)
    filterAttrs
    hasPrefix
    hasSuffix
    mapAttrsToList
    ;
in
{
  imports = mapAttrsToList (name: _: ./. + "/${name}") (
    filterAttrs (
      name: type:
      (type == "directory" || (hasSuffix ".nix" name && name != "default.nix")) && !(hasPrefix "." name)
    ) (builtins.readDir ./.)
  );
}
