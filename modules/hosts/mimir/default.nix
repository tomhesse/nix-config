{ self, ... }:
{
  configurations.nixos.mimir.module =
    { lib, pkgs, ... }:
    {
      imports = [
        self.diskoConfigurations.mimir
        self.modules.nixos.authelia
        self.modules.nixos.bazarr
        self.modules.nixos.common-cpu-intel
        self.modules.nixos.common-pc-ssd
        self.modules.nixos.grub
        self.modules.nixos.immich
        self.modules.nixos.jellyfin
        self.modules.nixos.lldap
        self.modules.nixos.minecraft
        self.modules.nixos.navidrome
        self.modules.nixos.nfs-server
        self.modules.nixos.paperless
        self.modules.nixos.podman
        self.modules.nixos.profilarr
        self.modules.nixos.prowlarr
        self.modules.nixos.radarr
        self.modules.nixos.sabnzbd
        self.modules.nixos.samba
        self.modules.nixos.sanoid
        self.modules.nixos.seerr
        self.modules.nixos.server
        self.modules.nixos.smartd
        self.modules.nixos.socket-proxy
        self.modules.nixos.sonarr
        self.modules.nixos.syncoid
        self.modules.nixos.traefik
        self.modules.nixos.user-thesse
        self.modules.nixos.zfs
      ];

      users.users.thesse.shell = lib.mkForce pkgs.bash;

      home-manager.users.thesse.imports = [
        self.modules.homeManager.server
      ];

      hardware.facter.reportPath = ./facter.json;

      networking.hostName = "mimir";

      system.stateVersion = "26.05";

      time.timeZone = "Europe/Berlin";
    };
}
