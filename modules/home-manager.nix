{ inputs, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  flake.modules.homeManager.home-manager =
    { osConfig, ... }:
    {
      home.stateVersion = osConfig.system.stateVersion;
    };
}
