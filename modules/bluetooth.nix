{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };

    environment.persistence."/persistent".directories = [
      "/var/lib/bluetooth"
    ];
  };
}
