{ inputs, ... }:
{
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
