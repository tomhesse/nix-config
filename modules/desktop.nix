{ self, ... }:
{
  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.wireless
    ];
  };
}
