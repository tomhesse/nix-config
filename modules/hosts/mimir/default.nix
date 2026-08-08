{ self, ... }:
{
  configurations.nixos.mimir.module =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        self.diskoConfigurations.mimir
        self.modules.nixos.alertmanager
        self.modules.nixos.arr
        self.modules.nixos.blackbox-exporter
        self.modules.nixos.clevis
        self.modules.nixos.common-cpu-intel
        self.modules.nixos.common-pc-ssd
        self.modules.nixos.grafana
        self.modules.nixos.grocy
        self.modules.nixos.homepage
        self.modules.nixos.jellyfin
        self.modules.nixos.kanidm
        self.modules.nixos.minecraft-server
        self.modules.nixos.mongodb
        self.modules.nixos.musivault
        self.modules.nixos.navidrome
        self.modules.nixos.nfs-server
        self.modules.nixos.node-exporter
        self.modules.nixos.oauth2-proxy
        self.modules.nixos.paperless
        self.modules.nixos.postgres-exporter
        self.modules.nixos.prometheus
        self.modules.nixos.restic-server
        self.modules.nixos.sanoid
        self.modules.nixos.secure-boot
        self.modules.nixos.server
        self.modules.nixos.smartctl-exporter
        self.modules.nixos.smartd
        self.modules.nixos.systemd-exporter
        self.modules.nixos.samba
        self.modules.nixos.user-ndahlke
        self.modules.nixos.user-thesse
        self.modules.nixos.zfs
      ];

      users.users.thesse.shell = lib.mkForce pkgs.bash;

      home-manager.users.thesse.imports = [
        self.modules.homeManager.server
      ];

      boot.initrd.availableKernelModules = [ "i40e" ];
      boot.kernelParams = [ "zfs.zfs_arc_max=${toString (32 * 1024 * 1024 * 1024)}" ];
      hardware.facter.reportPath = ./facter.json;

      disko.zfs.enable = true;

      systemd.tmpfiles.rules = [
        "z /srv/archive/games/osu 0755 thesse users -"
        "z /srv/media/music 0755 thesse users -"
        "a+ /srv/media/music - - - - default:user:navidrome:rX"
        "a+ /srv/media/video/anime/movies - - - - default:user:bazarr:rwX,default:user:radarr:rwX,user:bazarr:rwX,user:radarr:rwX"
        "a+ /srv/media/video/anime/shows - - - - default:user:bazarr:rwX,default:user:sonarr:rwX,user:bazarr:rwX,user:sonarr:rwX"
        "a+ /srv/media/video/movies - - - - default:user:bazarr:rwX,default:user:radarr:rwX,user:bazarr:rwX,user:radarr:rwX"
        "a+ /srv/media/video/shows - - - - default:user:bazarr:rwX,default:user:sonarr:rwX,user:bazarr:rwX,user:sonarr:rwX"
        "d /srv/backups/timemachine/ndahlke 0700 ndahlke ndahlke -"
      ];

      sops.secrets."services/samba/ndahlke/password".sopsFile = ./secrets/nixos.yaml;

      services = {
        grafana.provision.datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            url = "http://127.0.0.1:9090";
            isDefault = true;
            jsonData.timeInterval = "1m";
          }
        ];

        nfs.server.exports = ''
          /srv 10.0.10.0/24(ro,fsid=root)
          /srv/archive/games/osu tyr.shrimphouse.xyz(rw,sync,no_subtree_check)
          /srv/backups/homeassistant 10.0.20.20(rw,sync,no_subtree_check)
          /srv/media/music tyr.shrimphouse.xyz(rw,sync,no_subtree_check)
        '';

        samba.settings."timemachine-ndahlke" = {
          "comment" = "Time Machine Backup";
          "path" = "/srv/backups/timemachine/ndahlke";
          "valid users" = "ndahlke";
          "browsable" = "yes";
          "writable" = "yes";
          "vfs objects" = "catia fruit streams_xattr acl_xattr";
          "fruit:time machine" = "yes";
          "acl_xattr:ignore system acls" = "yes";
        };

        sanoid.datasets = {
          "rocket/services/bazarr".useTemplate = [ "frequent" ];
          "rocket/services/grafana".useTemplate = [ "frequent" ];
          "rocket/services/grocy".useTemplate = [ "frequent" ];
          "rocket/services/jellyfin".useTemplate = [ "frequent" ];
          "rocket/services/kanidm".useTemplate = [ "frequent" ];
          "rocket/services/mongodb".useTemplate = [ "frequent" ];
          "rocket/services/minecraft".useTemplate = [ "frequent" ];
          "rocket/services/musivault".useTemplate = [ "frequent" ];
          "rocket/services/navidrome".useTemplate = [ "frequent" ];
          "rocket/services/paperless".useTemplate = [ "frequent" ];
          "rocket/services/postgresql".useTemplate = [ "frequent" ];
          "rocket/services/prowlarr".useTemplate = [ "frequent" ];
          "rocket/services/prometheus".useTemplate = [ "frequent" ];
          "rocket/services/radarr".useTemplate = [ "frequent" ];
          "rocket/services/recyclarr".useTemplate = [ "frequent" ];
          "rocket/services/sabnzbd".useTemplate = [ "frequent" ];
          "rocket/services/sonarr".useTemplate = [ "frequent" ];
          "tank/archive/games/osu".useTemplate = [ "archive" ];
          "tank/backups/homeassistant".useTemplate = [ "backups" ];
          "tank/backups/restic/hosts/loki".useTemplate = [ "backups" ];
          "tank/backups/restic/hosts/tyr".useTemplate = [ "backups" ];
          "tank/backups/restic/services".useTemplate = [ "backups" ];
          "tank/backups/timemachine/ndahlke".useTemplate = [ "backups" ];
          "tank/media/music".useTemplate = [ "media" ];
          "tank/media/video/anime/movies".useTemplate = [ "media" ];
          "tank/media/video/anime/shows".useTemplate = [ "media" ];
          "tank/media/video/movies".useTemplate = [ "media" ];
          "tank/media/video/music".useTemplate = [ "media" ];
          "tank/media/video/shows".useTemplate = [ "media" ];
        };
      };

      systemd.services.samba-init-ndahlke = {
        description = "Initialize Samba password for ndahlke";
        wantedBy = [ "samba-smbd.service" ];
        before = [ "samba-smbd.service" ];
        after = [
          "sops-nix.service"
          "local-fs.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          mkdir -p /var/lib/samba/private
          if ! ${pkgs.samba}/bin/pdbedit -L 2>/dev/null | grep -q "^ndahlke:"; then
            password=$(cat ${config.sops.secrets."services/samba/ndahlke/password".path})
            printf '%s\n%s\n' "$password" "$password" | ${pkgs.samba}/bin/smbpasswd -a -s ndahlke
          fi
        '';
      };

      environment.persistCleanup.ignoredPaths = [ "/persistent/secrets" ];

      networking.hostId = "700e144e";
      networking.hostName = "mimir";

      system.stateVersion = "26.05";

      time.timeZone = "Europe/Berlin";
    };
}
