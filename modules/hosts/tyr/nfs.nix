{
  configurations.nixos.tyr.module = {
    fileSystems."/mnt/archive/games/osu" = {
      device = "mimir.shrimphouse.xyz:/srv/archive/games/osu";
      fsType = "nfs4";
      options = [
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
      ];
    };

    fileSystems."/mnt/music" = {
      device = "mimir.shrimphouse.xyz:/srv/media/music";
      fsType = "nfs4";
      options = [
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
      ];
    };
  };
}
