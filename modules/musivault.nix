# TODO: remove once nixpkgs#523085 is merged
{ inputs, ... }:
let
  overlay = _final: prev: {
    inherit (inputs.nixpkgs-musivault.legacyPackages.${prev.stdenv.hostPlatform.system}) musivault;
  };
in
{
  flake.overlays.musivault = overlay;

  flake.modules.nixos.musivault = {
    nixpkgs.overlays = [ overlay ];
    imports = [ "${inputs.nixpkgs-musivault}/nixos/modules/services/web-apps/musivault.nix" ];
  };
}
