{
  configurations.nixos.loki.module = {
    fileSystems."/mnt/music" = {
      device = "mimir.shrimphouse.xyz:/srv/media/music";
      fsType = "nfs4";
      options = [
        "noauto"
        "ro"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
      ];
    };
  };
}
