{ lib, ... }:
let
  importAll = import ../../../lib/importAll.nix { inherit lib; };
in
{
  imports = importAll ./.;
}
