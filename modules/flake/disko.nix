{ inputs, ... }:
{
  imports = [ inputs.disko.flakeModules.default ];

  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
