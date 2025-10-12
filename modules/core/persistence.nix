{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  rootDevice = config.fileSystems."/".device;

  btrfs-diff = pkgs.writeShellApplication {
    name = "btrfs-diff";
    runtimeInputs = builtins.attrValues {
      inherit (pkgs)
        btrfs-progs
        coreutils
        eza
        fd
        findutils
        util-linux
        ;
    };
    bashOptions = [
      "errexit"
      "pipefail"
    ];
    text = ''
      red() {
        echo -e "\x1B[31m[!] $1 \x1B[0m"
        if [ -n "''${2-}" ]; then
          echo -e "\x1B[31m[!] $($2) \x1B[0m"
        fi
      }

      green() {
        echo -e "\x1B[32m[+] $1 \x1B[0m"
        if [ -n "''${2-}" ]; then
          echo -e "\x1B[32m[+] $($2) \x1B[0m"
        fi
      }

      yellow() {
        echo -e "\x1B[33m[*] $1 \x1B[0m"
        if [ -n "''${2-}" ]; then
          echo -e "\x1B[33m[*] $($2) \x1B[0m"
        fi
      }

      help_and_exit() {
        echo
        echo "Check current root for any files that are not persisted."
        echo "(These files will be lost on a reboot.)"
        echo
        echo Optionally diff the current root with a previous root snapshot.
        echo
        echo "USAGE: $0 [OPTIONS]"
        echo
        echo "OPTIONS:"
        echo "  -b=<btrfs_vol>  Specify the btrfs volume to mount (default: ${rootDevice})"
        echo "  -s=<snapshot>   Specify the snapshot to diff against"
        echo "  --list-old      List the old roots only"
        echo "  -h, --help      Show this help message and exit"
        echo
        exit 1
      }

      if [ "$UID" -ne "0" ]; then
        red >&2 "ERROR: Must run as superuser to be able to mount main btrfs volume"
        exit 0
      fi

      SNAPSHOT=""
      MOUNTDIR=$(mktemp -d)
      BTRFS_VOL=${rootDevice}
      ROOT_LABEL=@
      OLD_ROOTS_LABEL=@old_roots
      LIST_OLD=0

      # Handle command-line arguments
      while [[ $# -gt 0 ]]; do
      case "$1" in
        --list-old)
        # List the old roots only
        LIST_OLD=1
        ;;
        -b*)
        BTRFS_VOL="''${1#*=}"
        ;;
        -s=*)
        SNAPSHOT="''${1#*=}"
        ;;
        --debug)
        set -x
        ;;
        -h | --help) help_and_exit ;;
        *)
        red "ERROR: Invalid option detected."
        help_and_exit
        ;;
        esac
        shift
      done

      ## Mount the btrfs root to a tmpdir so we can check the subvolumes for
      ## mismatching files.
      mount -t btrfs -o subvol=/ "''${BTRFS_VOL}" "''${MOUNTDIR}"

      ROOT_SUBVOL="''${MOUNTDIR}/''${ROOT_LABEL}"
      OLD_ROOTS_SUBVOL="''${MOUNTDIR}/''${OLD_ROOTS_LABEL}"

      if [ "''${LIST_OLD}" -eq 1 ]; then
        # List all the old roots
        green "Old roots:"
        cd "''${OLD_ROOTS_SUBVOL}"
        find . | tr ' ' '\n'
        cd - >/dev/null
      else
        # Diff the current root with a snapshot or list all current non-persisted files
        ROOT_FILES=$(cd "''${ROOT_SUBVOL}" && fd -I -H --type file --exclude '/tmp' | sort)

        if [ -n "''${SNAPSHOT}" ]; then
          # Diff the specified snapshot
          SNAPSHOT_SUBVOL="''${OLD_ROOTS_SUBVOL}/''${SNAPSHOT}"
          if [ ! -d "''${SNAPSHOT_SUBVOL}" ]; then
            red "ERROR: Snapshot ''${SNAPSHOT} does not exist. Use --list-old to list all available snapshots."
            exit 1
          fi
          SNAPSHOT_FILES=$(cd "''${SNAPSHOT_SUBVOL}" && fd -I -H --type file --exclude '/tmp' | sort)
          green "''${SNAPSHOT} has the following additional files missing from the current root:"
          cd "''${SNAPSHOT_SUBVOL}"

          while IFS= read -r file; do
            if [[ ! ''${ROOT_FILES} =~ ''${file} ]]; then
              eza "''${file}"
            fi
          done <<<"''${SNAPSHOT_FILES}"
          cd - >/dev/null
        else
          # Show new files on the current root volume only
          green "Ephemeral files on the current root:"
          cd "''${ROOT_SUBVOL}"
          while IFS= read -r file; do
            eza "/''${file}"
          done <<<"''${ROOT_FILES}"
          cd - >/dev/null
        fi
      fi
      umount "''${MOUNTDIR}"
      rmdir "''${MOUNTDIR}"
    '';
  };
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.systemPackages = [ btrfs-diff ];

  environment.persistence = {
    "/persist" = {
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/var/log"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  fileSystems."/persist".neededForBoot = true;

  programs.fuse.userAllowOther = true;

  system.activationScripts.persistent-dirs.text =
    let
      mkHomePersist =
        user:
        lib.optionalString user.createHome ''
          mkdir -p /persist/${user.home}
          chown ${user.name}:${user.group} /persist/${user.home}
          chmod ${user.homeMode} /persist/${user.home}
        '';
      users = lib.attrValues config.users.users;
    in
    lib.concatLines (map mkHomePersist users);

  boot.initrd.systemd = {
    initrdBin = builtins.attrValues {
      inherit (pkgs)
        bash
        btrfs-progs
        coreutils
        findutils
        util-linux
        ;
    };
    services.rotate-root-btrfs = {
      description = "Rotate Btrfs root subvolume before mounting sysroot (stage-1)";
      wantedBy = [ "initrd.target" ];
      after = [
        "cryptsetup.target"
      ];
      before = [
        "sysroot.mount"
      ];
      unitConfig = {
        DefaultDependencies = "no";
        ConditionPathExists = "${rootDevice}";
      };
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        #!/usr/bin/env bash

        mkdir /btrfs_tmp

        mount -t btrfs -o subvol=/ ${rootDevice} /btrfs_tmp

        if [[ -e /btrfs_tmp/@ ]]; then
          mkdir -p /btrfs_tmp/@old_roots || true
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

        find /btrfs_tmp/@old_roots/ -maxdepth 1 -mtime +30 | while read -r old; do
          delete_subvolume_recursively "$old"
        done

        btrfs subvolume create /btrfs_tmp/@
        umount /btrfs_tmp
      '';
    };
  };
}
