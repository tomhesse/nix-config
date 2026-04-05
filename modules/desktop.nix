{ self, ... }:
{
  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.base
      self.modules.nixos.hyprland
      self.modules.nixos.pipewire
      self.modules.nixos.plymouth
      self.modules.nixos.sddm
      self.modules.nixos.wireless
      self.modules.nixos.yubikey
      self.modules.nixos.zen-kernel
    ];

    home-manager.sharedModules = [
      self.modules.homeManager.desktop
    ];
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.base
      self.modules.homeManager.kitty
    ];
  };
}
