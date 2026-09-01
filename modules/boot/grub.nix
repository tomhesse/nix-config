{
  flake.modules.nixos.grub = {
    boot = {
      loader = {
        grub = {
          enable = true;
          efiSupport = true;
          efiInstallAsRemovable = true;
          copyKernels = true;
          configurationLimit = 10;
        };
        efi.canTouchEfiVariables = false;
      };
    };
  };
}
