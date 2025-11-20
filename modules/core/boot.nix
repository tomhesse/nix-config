{
  boot = {
    loader = {
      limine = {
        enable = true;
        enableEditor = false;
        maxGenerations = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.systemd.enable = true;
  };
}
