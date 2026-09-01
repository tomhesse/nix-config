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

      rpoolMember = {
        size = "100%";
        content = {
          type = "zfs";
          pool = "rpool";
        };
      };
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
                zfs = rpoolMember;
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
                zfs = rpoolMember;
              };
            };
          };
        };

        zpool.rpool = {
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

            reserved = {
              type = "zfs_fs";
              options = {
                canmount = "off";
                mountpoint = "none";
                refreservation = "44G";
              };
            };
          };
        };
      };
    };
}
