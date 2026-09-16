{ self, ... }:
{
  configurations.nixos.mimir.module =
    { lib, pkgs, ... }:
    {
      imports = [
        self.diskoConfigurations.mimir
        self.modules.nixos.authelia
        self.modules.nixos.bazarr
        self.modules.nixos.common-cpu-intel
        self.modules.nixos.common-pc-ssd
        self.modules.nixos.grub
        self.modules.nixos.jellyfin
        self.modules.nixos.lldap
        self.modules.nixos.minecraft
        self.modules.nixos.navidrome
        self.modules.nixos.nfs-server
        self.modules.nixos.paperless
        self.modules.nixos.podman
        self.modules.nixos.profilarr
        self.modules.nixos.prowlarr
        self.modules.nixos.radarr
        self.modules.nixos.sabnzbd
        self.modules.nixos.samba
        self.modules.nixos.sanoid
        self.modules.nixos.seerr
        self.modules.nixos.server
        self.modules.nixos.smartd
        self.modules.nixos.socket-proxy
        self.modules.nixos.sonarr
        self.modules.nixos.syncoid
        self.modules.nixos.traefik
        self.modules.nixos.user-thesse
        self.modules.nixos.zfs
      ];

      users.users.thesse.shell = lib.mkForce pkgs.bash;

      services.nfs.server.exports = ''
        /srv/archive/games/osu 10.0.10.11(rw,sync,no_subtree_check)
        /srv/media/music 10.0.10.11(rw,sync,no_subtree_check,all_squash,anonuid=406,anongid=406) 10.0.10.12(ro,sync,no_subtree_check,all_squash,anonuid=406,anongid=406)
      '';

      systemd.tmpfiles.rules = [
        "z /srv/archive/games/osu 0700 thesse users -"
        "z /srv/cache/jellyfin 0700 jellyfin jellyfin -"
        "d /srv/downloads/complete 0775 sabnzbd sabnzbd -"
        "d /srv/downloads/incomplete 0750 sabnzbd sabnzbd -"
        "z /srv/media/music 0700 navidrome navidrome -"
        "z /srv/media/video/anime/movies 0775 root root -"
        "z /srv/media/video/anime/shows 0775 root root -"
        "z /srv/media/video/movies 0775 root root -"
        "z /srv/media/video/shows 0775 root root -"
        "a+ /srv/downloads/complete - - - - default:mask::rwx"
        "a+ /srv/downloads/complete - - - - default:user:radarr:rwX,user:radarr:rwX"
        "a+ /srv/downloads/complete - - - - default:user:sonarr:rwX,user:sonarr:rwX"
        "a+ /srv/media/video/anime/movies - - - - default:mask::rwx"
        "a+ /srv/media/video/anime/movies - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/anime/movies - - - - default:user:bazarr:rwX,user:bazarr:rwX"
        "a+ /srv/media/video/anime/movies - - - - default:user:radarr:rwX,user:radarr:rwX"
        "a+ /srv/media/video/anime/shows - - - - default:mask::rwx"
        "a+ /srv/media/video/anime/shows - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/anime/shows - - - - default:user:bazarr:rwX,user:bazarr:rwX"
        "a+ /srv/media/video/anime/shows - - - - default:user:sonarr:rwX,user:sonarr:rwX"
        "a+ /srv/media/video/movies - - - - default:mask::rwx"
        "a+ /srv/media/video/movies - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/movies - - - - default:user:bazarr:rwX,user:bazarr:rwX"
        "a+ /srv/media/video/movies - - - - default:user:radarr:rwX,user:radarr:rwX"
        "a+ /srv/media/video/shows - - - - default:mask::rwx"
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
