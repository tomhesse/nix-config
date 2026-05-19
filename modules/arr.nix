{ self, ... }:
{
  flake.modules.nixos.arr = {
    imports = [
      self.modules.nixos.bazarr
      self.modules.nixos.exportarr-bazarr
      self.modules.nixos.exportarr-prowlarr
      self.modules.nixos.exportarr-radarr
      self.modules.nixos.exportarr-sonarr
      self.modules.nixos.prowlarr
      self.modules.nixos.radarr
      self.modules.nixos.recyclarr
      self.modules.nixos.sabnzbd
      self.modules.nixos.sabnzbd-exporter
      self.modules.nixos.sonarr
    ];
  };
}
