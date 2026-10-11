{
  configurations.nixos.mimir.module = {
    boot.loader.grub.mirroredBoots = [
      {
        path = "/boot1";
        devices = [ "nodev" ];
      }
      {
        path = "/boot2";
        devices = [ "nodev" ];
      }
    ];
  };
}
