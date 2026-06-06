{ inputs, ... }:
{
  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
  };

  flake.modules.nixos.impermanence =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        concatStringsSep
        escapeShellArg
        flatten
        mapAttrsToList
        mkOption
        types
        unique
        ;

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

      storageDir = e: e.persistentStoragePath + e.dirPath;
      storageFile = e: e.persistentStoragePath + e.filePath;

      nixosPaths = flatten (
        mapAttrsToList (
          _base: persis: (map storageFile persis.files) ++ (map storageDir persis.directories)
        ) config.environment.persistence
      );

      hmUsers = config.home-manager.users or { };
      hmPaths = flatten (
        mapAttrsToList (
          _user: hmCfg:
          flatten (
            mapAttrsToList (
              _base: persis: (map storageFile persis.files) ++ (map storageDir persis.directories)
            ) hmCfg.home.persistence
          )
        ) hmUsers
      );

      persistBases = unique (
        builtins.attrNames config.environment.persistence
        ++ flatten (mapAttrsToList (_user: hmCfg: builtins.attrNames hmCfg.home.persistence) hmUsers)
      );

      persist-cleanup = pkgs.writeShellApplication {
        name = "persist-cleanup";
        runtimeInputs = with pkgs; [
          coreutils
          findutils
        ];
        text = ''
          if [[ $EUID -ne 0 ]]; then
            echo "Error: must be run as root" >&2
            exit 1
          fi

          DRY_RUN=0
          if [[ "''${1:-}" == "--dry-run" ]]; then
            DRY_RUN=1
          fi

          declared=(
            ${concatStringsSep "\n  " (
              map escapeShellArg (nixosPaths ++ hmPaths ++ config.environment.persistCleanup.ignoredPaths)
            )}
          )

          persist_bases=(
            ${concatStringsSep "\n  " (map escapeShellArg persistBases)}
          )

          is_needed() {
            local path="$1" d
            for d in "''${declared[@]}"; do
              [[ "$path" == "$d" ]] && return 0
              [[ "$path" == "$d/"* ]] && return 0
              [[ "$d" == "$path/"* ]] && return 0
            done
            return 1
          }

          is_parent_only() {
            local path="$1" d
            for d in "''${declared[@]}"; do
              [[ "$d" == "$path/"* ]] && return 0
            done
            return 1
          }

          orphans=()

          scan() {
            local dir="$1" entry
            while IFS= read -r -d "" entry; do
              if ! is_needed "$entry"; then
                orphans+=("$entry")
              elif [[ -d "$entry" ]] && is_parent_only "$entry"; then
                scan "$entry"
              fi
            done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null || true)
          }

          for base in "''${persist_bases[@]}"; do
            [[ -d "$base" ]] && scan "$base"
          done

          if [[ ''${#orphans[@]} -eq 0 ]]; then
            echo "Nothing to clean up — all paths in the persistence store are declared."
            exit 0
          fi

          echo "Orphaned paths in the persistence store not declared for ${config.networking.hostName}:"
          for o in "''${orphans[@]}"; do
            echo "  $o"
          done

          if [[ "$DRY_RUN" -eq 1 ]]; then
            exit 0
          fi

          echo ""
          read -r -p "Delete all of the above? [y/N] " confirm
          if [[ "$confirm" == [yY]* ]]; then
            for o in "''${orphans[@]}"; do
              rm -rf -- "$o"
              echo "Deleted: $o"
            done
            echo "Done."
          else
            echo "Aborted."
          fi
        '';
      };
    in
    {
      options.environment.persistCleanup.ignoredPaths = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Paths under persistent storage that exist outside of environment.persistence and home.persistence and should not be flagged as orphans by persist-cleanup.";
      };

      imports = [ inputs.impermanence.nixosModules.impermanence ];

      config = {
        environment.systemPackages = [
          btrfs-diff
          persist-cleanup
        ];

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
            "/var/lib/systemd/backlight"
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
    };
}
