{ lib, ... }:
let
  entries = lib.filterAttrs (
    name: type:
    (type == "directory" || (lib.hasSuffix ".nix" name && name != "default.nix"))
    && !(lib.hasPrefix "." name)
  ) (builtins.readDir ./.);

  toPair =
    name: _:
    let
      path = ./. + "/${name}";
      key = if lib.hasSuffix ".nix" name then lib.removeSuffix ".nix" name else name;
    in
    lib.nameValuePair key (import path);
in
{
  flake.overlays = lib.listToAttrs (lib.mapAttrsToList toPair entries);
}
