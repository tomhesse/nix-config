{ self, ... }:
{
  configurations.nixos.mimir.module =
    { lib, pkgs, ... }:
    {
      imports = [
        self.diskoConfigurations.mimir
        self.modules.nixos.arr
        self.modules.nixos.clevis
        self.modules.nixos.common-cpu-intel
        self.modules.nixos.common-pc-ssd
        self.modules.nixos.grocy
        self.modules.nixos.kanidm
        self.modules.nixos.navidrome
        self.modules.nixos.nfs-server
        self.modules.nixos.oauth2-proxy
        self.modules.nixos.paperless
        self.modules.nixos.restic-server
        self.modules.nixos.sanoid
        self.modules.nixos.secure-boot
        self.modules.nixos.server
        self.modules.nixos.smartd
        self.modules.nixos.user-thesse
        self.modules.nixos.zfs
      ];

      users.users.thesse.shell = lib.mkForce pkgs.bash;

      home-manager.users.thesse.imports = [
        self.modules.homeManager.server
      ];

      boot.initrd.availableKernelModules = [ "i40e" ];
      boot.initrd.clevis.devices."mimir".secretFile = /persistent/secrets/clevis/mimir.jwe;

      hardware.facter.reportPath = ./facter.json;

      disko.zfs.enable = true;

      systemd.tmpfiles.rules = [
        "z /srv/media/music 0755 thesse users -"
        "a+ /srv/media/music - - - - default:user:navidrome:rX"
      ];

      services.nfs.server.exports = ''
        /srv 10.0.10.0/24(ro,fsid=root)
        /srv/media/music tyr.shrimphouse.xyz(rw,sync,no_subtree_check)
      '';

      services.sanoid.datasets = {
        "rocket/services/grocy".useTemplate = [ "frequent" ];
        "rocket/services/kanidm".useTemplate = [ "frequent" ];
        "rocket/services/navidrome".useTemplate = [ "frequent" ];
        "rocket/services/paperless".useTemplate = [ "frequent" ];
        "rocket/services/postgresql".useTemplate = [ "frequent" ];
        "rocket/services/prowlarr".useTemplate = [ "frequent" ];
        "rocket/services/radarr".useTemplate = [ "frequent" ];
        "tank/backups/restic/hosts/loki".useTemplate = [ "backups" ];
        "tank/backups/restic/hosts/tyr".useTemplate = [ "backups" ];
        "tank/backups/restic/services".useTemplate = [ "backups" ];
        "tank/media/music".useTemplate = [ "media" ];
      };

      networking.hostId = "700e144e";
      networking.hostName = "mimir";

      system.stateVersion = "25.11";

      time.timeZone = "Europe/Berlin";
    };
}
