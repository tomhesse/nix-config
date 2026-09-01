{
  flake.modules.nixos.limine = {
    boot = {
      loader = {
        limine = {
          enable = true;
          enableEditor = false;
          maxGenerations = 10;
        };
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
