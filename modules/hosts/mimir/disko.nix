{
  flake.diskoConfigurations.mimir =
    let
      esp = mountpoint: {
        size = "2G";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          inherit mountpoint;
          mountOptions = [
            "umask=0077"
            "nofail"
          ];
        };
      };

      zfsPartition = pool: {
        size = "100%";
        content = {
          type = "zfs";
          inherit pool;
        };
      };

      zfsDisk = pool: device: {
        type = "disk";
        inherit device;
        content = {
          type = "gpt";
          partitions.zfs = zfsPartition pool;
        };
      };

      dataset = options: {
        type = "zfs_fs";
        inherit options;
      };

      container =
        options:
        dataset (
          {
            canmount = "off";
          }
          // options
        );
    in
    {
      disko.devices = {
        disk = {
          ssd0 = {
            type = "disk";
            device = "/dev/disk/by-id/wwn-0x5002538f5531e4d4";
            content = {
              type = "gpt";
              partitions = {
                esp = esp "/boot1";
                zfs = zfsPartition "rpool";
              };
            };
          };

          ssd1 = {
            type = "disk";
            device = "/dev/disk/by-id/wwn-0x5002538f5531e4d5";
            content = {
              type = "gpt";
              partitions = {
                esp = esp "/boot2";
                zfs = zfsPartition "rpool";
              };
            };
          };

          tank0 = zfsDisk "tank" "/dev/disk/by-id/wwn-0x5000cca278d64ea0";
          tank1 = zfsDisk "tank" "/dev/disk/by-id/wwn-0x5000cca278d64f1f";
          tank2 = zfsDisk "tank" "/dev/disk/by-id/wwn-0x5000cca278d63046";
          tank3 = zfsDisk "tank" "/dev/disk/by-id/wwn-0x5000cca27ac59544";
          tank4 = zfsDisk "tank" "/dev/disk/by-id/wwn-0x5000cca278d63e40";
          tank5 = zfsDisk "tank" "/dev/disk/by-id/wwn-0x5000cca278d67452";
          tank6 = zfsDisk "tank" "/dev/disk/by-id/wwn-0x5000cca278d67451";
          tank7 = zfsDisk "tank" "/dev/disk/by-id/wwn-0x5000cca278d5e643";

          scratch0 = zfsDisk "scratch" "/dev/disk/by-id/nvme-nvme.8086-50484d42383032323030384334383044474e-494e54454c2053534450454431443438304741-00000001";
        };

        zpool = {
          rpool = {
            type = "zpool";
            mode = "mirror";
            options.ashift = "12";

            rootFsOptions = {
              acltype = "posixacl";
              atime = "off";
              canmount = "off";
              compression = "zstd";
              mountpoint = "none";
              xattr = "sa";
            };

            datasets = {
              root = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/";
              };

              nix = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/nix";
              };

              containers = dataset {
                mountpoint = "/var/lib/containers";
              };

              reserved = container {
                mountpoint = "none";
                refreservation = "44G";
              };

              services = container {
                mountpoint = "/srv/services";
                recordsize = "16K";
              };

              "services/authelia" = dataset {
                mountpoint = "/srv/services/authelia";
              };

              "services/bazarr" = dataset {
                mountpoint = "/srv/services/bazarr";
              };

              "services/jellyfin" = dataset {
                mountpoint = "/srv/services/jellyfin";
              };

              "services/lldap" = dataset {
                mountpoint = "/srv/services/lldap";
              };

              "services/profilarr" = dataset {
                mountpoint = "/srv/services/profilarr";
              };

              "services/prowlarr" = dataset {
                mountpoint = "/srv/services/prowlarr";
              };

              "services/radarr" = dataset {
                mountpoint = "/srv/services/radarr";
              };

              "services/sabnzbd" = dataset {
                mountpoint = "/srv/services/sabnzbd";
              };

              "services/seerr" = dataset {
                mountpoint = "/srv/services/seerr";
              };

              "services/sonarr" = dataset {
                mountpoint = "/srv/services/sonarr";
              };

              "services/traefik" = dataset {
                mountpoint = "/srv/services/traefik";
              };
            };
          };

          tank = {
            type = "zpool";
            mode = "raidz3";
            options.ashift = "12";

            rootFsOptions = {
              acltype = "posixacl";
              atime = "off";
              canmount = "off";
              compression = "off";
              mountpoint = "none";
              xattr = "sa";
            };

            datasets = {
              backups = container {
                mountpoint = "/srv/backups";
              };

              media = container {
                mountpoint = "/srv/media";
                recordsize = "1M";
              };

              "media/video" = container {
                mountpoint = "/srv/media/video";
              };

              "media/video/anime" = container {
                mountpoint = "/srv/media/video/anime";
              };

              "media/video/anime/movies" = dataset {
                mountpoint = "/srv/media/video/anime/movies";
              };

              "media/video/anime/shows" = dataset {
                mountpoint = "/srv/media/video/anime/shows";
              };

              "media/video/movies" = dataset {
                mountpoint = "/srv/media/video/movies";
              };

              "media/video/shows" = dataset {
                mountpoint = "/srv/media/video/shows";
              };
            };
          };

          scratch = {
            type = "zpool";
            options.ashift = "12";

            rootFsOptions = {
              acltype = "posixacl";
              atime = "off";
              canmount = "off";
              compression = "off";
              mountpoint = "none";
              xattr = "sa";
            };

            datasets = {
              cache = container {
                mountpoint = "/srv/cache";
              };

              "cache/jellyfin" = dataset {
                mountpoint = "/srv/cache/jellyfin";
                reservation = "20G";
              };

              downloads = container {
                mountpoint = "/srv/downloads";
                recordsize = "1M";
              };

              "downloads/complete" = dataset {
                mountpoint = "/srv/downloads/complete";
              };

              "downloads/incomplete" = dataset {
                mountpoint = "/srv/downloads/incomplete";
              };
            };
          };
        };
      };
    };
}
