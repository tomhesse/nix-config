{ self, ... }:
{
  flake.modules.nixos.arr = {
    imports = [
      self.modules.nixos.prowlarr
      self.modules.nixos.radarr
      self.modules.nixos.recyclarr
      self.modules.nixos.sabnzbd
      self.modules.nixos.sonarr
    ];
  };
}
