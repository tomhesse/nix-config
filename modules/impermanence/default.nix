{ inputs, ... }:
{
  flake.modules.nixos.impermanence =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      rootDevice = config.fileSystems."/".device;
      hasLuks = config.boot.initrd.luks.devices != { };

      btrfs-diff = pkgs.writeShellApplication {
        name = "btrfs-diff";
        runtimeInputs = with pkgs; [
          btrfs-progs
          coreutils
          eza
          fd
          findutils
          util-linux
        ];
        bashOptions = [
          "errexit"
          "pipefail"
        ];
        text = builtins.readFile ./btrfs-diff.sh;
      };
    in
    {
      imports = [ inputs.impermanence.nixosModules.impermanence ];

      environment.systemPackages = [ btrfs-diff ];

      boot.initrd.systemd.initrdBin = with pkgs; [
        btrfs-progs
        coreutils
        findutils
        util-linux
      ];

      fileSystems."/persistent".neededForBoot = true;

      environment.persistence."/persistent" = {
        directories = [
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/timers"
          "/var/log"
        ];
        files = [
          "/etc/machine-id"
          "/var/lib/systemd/random-seed"
        ];
      };

      boot.initrd.systemd.services.rotate-root-btrfs = {
        description = "Rotate Btrfs root subvolume before mounting sysroot";
        wantedBy = [ "initrd.target" ];
        after = lib.optionals hasLuks [ "cryptsetup.target" ];
        before = [ "sysroot.mount" ];
        unitConfig = {
          DefaultDependencies = "no";
          ConditionPathExists = rootDevice;
        };
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /btrfs_tmp
          mount -t btrfs -o subvol=/ ${rootDevice} /btrfs_tmp

          cleanup() {
            umount /btrfs_tmp 2>/dev/null || true
            rmdir /btrfs_tmp 2>/dev/null || true
          }
          trap cleanup EXIT

          if [[ -e /btrfs_tmp/@ ]]; then
            mkdir -p /btrfs_tmp/@old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%d_%H:%M:%S")
            mv /btrfs_tmp/@ "/btrfs_tmp/@old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          if [[ -d /btrfs_tmp/@old_roots ]]; then
            find /btrfs_tmp/@old_roots/ -maxdepth 1 -mtime +30 | while read -r old; do
              delete_subvolume_recursively "$old"
            done
          fi

          btrfs subvolume create /btrfs_tmp/@
        '';
      };
    };
}
