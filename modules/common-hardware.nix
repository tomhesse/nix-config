{ inputs, ... }:
{
  flake.modules.nixos = {
    common-cpu-intel = {
      imports = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel
      ];
    };

    common-gpu-nvidia-nonprime = {
      imports = [
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
      ];
    };

    common-pc-ssd = {
      imports = [
        inputs.nixos-hardware.nixosModules.common-pc-ssd
      ];
    };
  };
}
