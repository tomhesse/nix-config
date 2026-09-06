{ self, ... }:
{
  configurations.nixos.mimir.module =
    { lib, pkgs, ... }:
    {
      imports = [
        self.diskoConfigurations.mimir
        self.modules.nixos.authelia
        self.modules.nixos.common-cpu-intel
        self.modules.nixos.common-pc-ssd
        self.modules.nixos.grub
        self.modules.nixos.jellyfin
        self.modules.nixos.lldap
        self.modules.nixos.podman
        self.modules.nixos.prowlarr
        self.modules.nixos.sabnzbd
        self.modules.nixos.server
        self.modules.nixos.smartd
        self.modules.nixos.socket-proxy
        self.modules.nixos.traefik
        self.modules.nixos.user-thesse
        self.modules.nixos.zfs
      ];

      users = {
        users = {
          thesse.shell = lib.mkForce pkgs.bash;

          bazarr = {
            isSystemUser = true;
            group = "bazarr";
            uid = 405;
          };

          jellyfin = {
            isSystemUser = true;
            group = "jellyfin";
            uid = 400;
          };

          prowlarr = {
            isSystemUser = true;
            group = "prowlarr";
            uid = 403;
          };

          radarr = {
            isSystemUser = true;
            group = "radarr";
            uid = 402;
          };

          sabnzbd = {
            isSystemUser = true;
            group = "sabnzbd";
            uid = 404;
          };

          sonarr = {
            isSystemUser = true;
            group = "sonarr";
            uid = 401;
          };
        };

        groups = {
          bazarr.gid = 405;
          jellyfin.gid = 400;
          prowlarr.gid = 403;
          radarr.gid = 402;
          sabnzbd.gid = 404;
          sonarr.gid = 401;
        };
      };

      systemd.tmpfiles.rules = [
        "z /srv/cache/jellyfin 0700 jellyfin jellyfin -"
        "d /srv/downloads/complete 0755 sabnzbd sabnzbd -"
        "d /srv/downloads/incomplete 0750 sabnzbd sabnzbd -"
        "a+ /srv/downloads/complete - - - - default:user:radarr:rwX,user:radarr:rwX"
        "a+ /srv/downloads/complete - - - - default:user:sonarr:rwX,user:sonarr:rwX"
        "a+ /srv/media/video/anime/movies - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/anime/movies - - - - default:user:bazarr:rwX,user:bazarr:rwX"
        "a+ /srv/media/video/anime/movies - - - - default:user:radarr:rwX,user:radarr:rwX"
        "a+ /srv/media/video/anime/shows - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/anime/shows - - - - default:user:bazarr:rwX,user:bazarr:rwX"
        "a+ /srv/media/video/anime/shows - - - - default:user:sonarr:rwX,user:sonarr:rwX"
        "a+ /srv/media/video/movies - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/movies - - - - default:user:bazarr:rwX,user:bazarr:rwX"
        "a+ /srv/media/video/movies - - - - default:user:radarr:rwX,user:radarr:rwX"
        "a+ /srv/media/video/shows - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/shows - - - - default:user:bazarr:rwX,user:bazarr:rwX"
        "a+ /srv/media/video/shows - - - - default:user:sonarr:rwX,user:sonarr:rwX"
      ];

      home-manager.users.thesse.imports = [
        self.modules.homeManager.server
      ];

      boot = {
        kernelParams = [ "zfs.zfs_arc_max=${toString (32 * 1024 * 1024 * 1024)}" ];

        loader.grub.mirroredBoots = [
          {
            path = "/boot1";
            devices = [ "nodev" ];
          }
          {
            path = "/boot2";
            devices = [ "nodev" ];
          }
        ];

        zfs.extraPools = [
          "scratch"
          "tank"
        ];
      };

      hardware.facter.reportPath = ./facter.json;

      disko.zfs.enable = true;

      environment.persistence."/persistent".enable = false;

      networking.hostId = "700e144e";
      networking.hostName = "mimir";

      system.stateVersion = "26.05";

      time.timeZone = "Europe/Berlin";
    };
}
