{ self, ... }:
{
  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.pipewire
      self.modules.nixos.wireless
    ];
  };
}
