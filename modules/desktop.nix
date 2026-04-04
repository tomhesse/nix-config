{ self, ... }:
{
  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.hyprland
      self.modules.nixos.pipewire
      self.modules.nixos.sddm
      self.modules.nixos.wireless
    ];
  };
}
