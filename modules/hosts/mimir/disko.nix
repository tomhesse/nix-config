{
  flake.diskoConfigurations.mimir = {
    disko.devices = {
      disk = {
        boot = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-nvme.8086-50484d42383032323030384334383044474e-494e54454c2053534450454431443438304741-00000001";
          content = {
            type = "gpt";
            partitions = {
              esp = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "mimir";
                  settings.allowDiscards = true;
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-Lmimir" ];
                    subvolumes = {
                      "@" = {
                        mountpoint = "/";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@persistent" = {
                        mountpoint = "/persistent";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                    };
                  };
                };
              };
            };
          };
        };

        rocket0 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5002538f5531e4d4";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rocket";
              };
            };
          };
        };
        rocket1 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5002538f5531e4d5";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rocket";
              };
            };
          };
        };

        tank0 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000cca278d64ea0";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
        tank1 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000cca278d64f1f";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
        tank2 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000cca278d63046";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
        tank3 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000cca27ac59544";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
        tank4 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000cca278d63e40";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
        tank5 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000cca278d67452";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
        tank6 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000cca278d67451";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
        tank7 = {
          type = "disk";
          device = "/dev/disk/by-id/wwn-0x5000cca278d5e643";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };

      zpool = {
        rocket = {
          type = "zpool";
          mode = "mirror";
          options.ashift = "12";
          rootFsOptions = {
            atime = "off";
            canmount = "off";
            compression = "zstd";
            encryption = "aes-256-gcm";
            keyformat = "raw";
            keylocation = "file:///persistent/secrets/zfs/rocket.key";
            mountpoint = "none";
          };
          datasets = {
            "services" = {
              type = "zfs_fs";
              options = {
                canmount = "off";
                mountpoint = "none";
              };
            };
            "services/kanidm" = {
              type = "zfs_fs";
              options = {
                mountpoint = "legacy";
                recordsize = "64K";
              };
              mountpoint = "/var/lib/kanidm";
            };
            "services/navidrome" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/var/lib/navidrome";
            };
            "services/paperless" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/var/lib/paperless";
            };
            "services/postgresql" = {
              type = "zfs_fs";
              options = {
                mountpoint = "legacy";
                recordsize = "8K";
              };
              mountpoint = "/var/lib/postgresql";
            };
          };
        };

        tank = {
          type = "zpool";
          mode = {
            topology = {
              type = "topology";
              vdev = [
                {
                  mode = "raidz2";
                  members = [
                    "tank0"
                    "tank2"
                    "tank4"
                    "tank6"
                  ];
                }
                {
                  mode = "raidz2";
                  members = [
                    "tank1"
                    "tank3"
                    "tank5"
                    "tank7"
                  ];
                }
              ];
            };
          };
          options.ashift = "12";
          rootFsOptions = {
            atime = "off";
            canmount = "off";
            compression = "zstd";
            encryption = "aes-256-gcm";
            keyformat = "raw";
            keylocation = "file:///persistent/secrets/zfs/tank.key";
            mountpoint = "none";
          };
          datasets = {
            "media" = {
              type = "zfs_fs";
              options = {
                canmount = "off";
                mountpoint = "none";
              };
            };
            "media/music" = {
              type = "zfs_fs";
              options = {
                mountpoint = "legacy";
                acltype = "posixacl";
              };
              mountpoint = "/srv/media/music";
            };
          };
        };
      };
    };
  };
}
