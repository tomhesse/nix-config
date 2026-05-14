{ self, ... }:
{
  flake.modules.nixos.arr = {
    imports = [
      self.modules.nixos.prowlarr
      self.modules.nixos.radarr
    ];
  };
}
