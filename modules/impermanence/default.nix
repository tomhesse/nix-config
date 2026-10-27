{ inputs, self, ... }:
{
  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
  };

  flake.modules.nixos.persistence =
    { config, lib, ... }:
    let
      inherit (lib)
        mkOption
        types
        ;
    in
    {
      options.environment.persistCleanup.ignoredPaths = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Paths under persistent storage that exist outside of environment.persistence and home.persistence and should not be flagged as orphans by persist-cleanup.";
      };

      imports = [ inputs.impermanence.nixosModules.impermanence ];

      config = {
        # The ephemeral root itself lives in the impermanence module, which hosts
        # import individually. A host that declares persisted paths but forgets that
        # import is caught by impermanence's own neededForBoot assertion.
        environment.persistence."/persistent" = {
          hideMounts = true;
          allowTrash = true;
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

        home-manager.sharedModules = [
          {
            home.persistence."/persistent" = {
              inherit (config.environment.persistence."/persistent") enable;
              hideMounts = true;
              allowTrash = true;
            };
          }
        ];
      };
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
        flatten
        mapAttrsToList
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
        runtimeEnv = {
          host_name = config.networking.hostName;
          declared = nixosPaths ++ hmPaths ++ config.environment.persistCleanup.ignoredPaths;
          persist_bases = persistBases;
        };
        text = builtins.readFile ./persist-cleanup.sh;
      };
    in
    {
      imports = [ self.modules.nixos.persistence ];

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
