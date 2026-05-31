{
  flake.modules.nixos.boot = {
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
