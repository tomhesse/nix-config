{ inputs, ... }:
{
  imports = [ inputs.disko.flakeModules.default ];

  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs = {
        disko.follows = "disko";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  flake.modules.nixos.disko = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.disko-zfs.nixosModules.default
    ];

    disko.zfs.enable = true;
  };
}
