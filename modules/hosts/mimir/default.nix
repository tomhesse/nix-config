{ self, ... }:
{
  configurations.nixos.mimir.module =
    { lib, pkgs, ... }:
    {
      imports = [
        self.diskoConfigurations.mimir
        self.modules.nixos.clevis
        self.modules.nixos.common-cpu-intel
        self.modules.nixos.common-pc-ssd
        self.modules.nixos.kanidm
        self.modules.nixos.navidrome
        self.modules.nixos.nfs-server
        self.modules.nixos.oauth2-proxy
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
        "Z /srv/media/music 0755 thesse users -"
      ];

      services.nfs.server.exports = ''
        /srv 10.0.10.0/24(ro,fsid=root)
        /srv/media/music tyr(rw,sync,no_subtree_check)
      '';

      networking.hostId = "700e144e";
      networking.hostName = "mimir";

      system.stateVersion = "25.11";

      time.timeZone = "Europe/Berlin";
    };
}
