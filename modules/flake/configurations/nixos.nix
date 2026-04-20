{
  self,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mapAttrsToList
    mkMerge
    mkOption
    nixosSystem
    types
    ;
in
{
  options.configurations.nixos = mkOption {
    type = types.lazyAttrsOf (
      types.submodule {
        options.module = mkOption {
          type = types.deferredModule;
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations = mapAttrs (
      _name:
      { module }:
      nixosSystem {
        modules = [
          { system.configurationRevision = self.rev or self.dirtyRev or null; }
          module
        ];
      }
    ) config.configurations.nixos;

    checks = mkMerge (
      mapAttrsToList (name: nixos: {
        ${nixos.config.nixpkgs.hostPlatform.system} = {
          "configurations/nixos/${name}" = nixos.config.system.build.toplevel;
        };
      }) config.flake.nixosConfigurations
    );
  };
}
