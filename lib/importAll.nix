{ lib }:
dir:
lib.mapAttrsToList (name: _: dir + "/${name}") (
  lib.filterAttrs (
    name: type:
    (type == "directory" || (lib.hasSuffix ".nix" name && name != "default.nix"))
    && !(lib.hasPrefix "." name)
  ) (builtins.readDir dir)
)
