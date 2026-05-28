{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
in
{
  options.configurations.home-manager = mkOption {
    type = types.lazyAttrsOf (
      types.submodule {
        options = {
          module = mkOption {
            type = types.deferredModule;
          };
          system = mkOption {
            type = types.str;
            default = "x86_64-linux";
          };
        };
      }
    );
    default = { };
  };

  config.flake.homeConfigurations = mapAttrs (
    _name:
    { module, system }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [
        "${inputs.impermanence}/home-manager.nix"
        {
          home._nixosModuleImported = true;
          home.persistence."/persistent".enable = false;
        }
        module
      ];
    }
  ) config.configurations.home-manager;
}
