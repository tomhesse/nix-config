{ self, ... }:
{
  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.base
      self.modules.nixos.hyprland
      self.modules.nixos.monitors
      self.modules.nixos.pipewire
      self.modules.nixos.plymouth
      self.modules.nixos.sddm
      self.modules.nixos.wireless
      self.modules.nixos.yubikey
      self.modules.nixos.zen-kernel
    ];

  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.base
      self.modules.homeManager.cliphist
      self.modules.homeManager.fonts
      self.modules.homeManager.hyprlock
      self.modules.homeManager.hyprpaper
      self.modules.homeManager.kitty
      self.modules.homeManager.rofi
    ];
  };
}
