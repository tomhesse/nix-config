{
  configurations.nixos.mimir.module =
    { lib, ... }:
    {
      boot = {
        kernelParams = [ "zfs.zfs_arc_max=${toString (32 * 1024 * 1024 * 1024)}" ];

        zfs.extraPools = [
          "scratch"
          "tank"
        ];
      };

      disko.zfs.enable = true;

      environment.persistence."/persistent".enable = false;

      networking.hostId = "700e144e";

      systemd.tmpfiles.rules = lib.mkBefore [
        "z /srv/archive/games/osu 0700 thesse users -"
        "z /srv/media/video/anime/movies 0775 root root -"
        "z /srv/media/video/anime/shows 0775 root root -"
        "z /srv/media/video/movies 0775 root root -"
        "z /srv/media/video/shows 0775 root root -"
        "a+ /srv/downloads/complete - - - - default:mask::rwx"
        "a+ /srv/media/video/anime/movies - - - - default:mask::rwx"
        "a+ /srv/media/video/anime/shows - - - - default:mask::rwx"
        "a+ /srv/media/video/movies - - - - default:mask::rwx"
        "a+ /srv/media/video/shows - - - - default:mask::rwx"
      ];
    };
}
