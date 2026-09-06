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
        self.modules.nixos.lldap
        self.modules.nixos.podman
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

          jellyfin = {
            isSystemUser = true;
            group = "jellyfin";
            uid = 400;
          };
        };

        groups.jellyfin.gid = 400;
      };

      systemd.tmpfiles.rules = [
        "z /srv/cache/jellyfin 0700 jellyfin jellyfin -"
        "a+ /srv/media/video/anime/movies - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/anime/shows - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/movies - - - - default:user:jellyfin:rX,user:jellyfin:rX"
        "a+ /srv/media/video/shows - - - - default:user:jellyfin:rX,user:jellyfin:rX"
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
