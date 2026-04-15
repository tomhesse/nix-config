{ inputs, ... }:
{
  flake.modules.nixos.framework-13-7040-amd = {
    imports = [
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ];
  };
}
