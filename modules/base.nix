{ self, ... }:
{
  flake.modules.nixos.base = {
    imports = [
      self.modules.nixos.boot
      self.modules.nixos.fish
      self.modules.nixos.home-manager
      self.modules.nixos.impermanence
      self.modules.nixos.locale
      self.modules.nixos.nix
      self.modules.nixos.openssh
      self.modules.nixos.sops
      self.modules.nixos.sudo
      self.modules.nixos.theme
      self.modules.nixos.time
      self.modules.nixos.users
      self.modules.nixos.zram
    ];
  };

  flake.modules.homeManager.base = {
    imports = [
      self.modules.homeManager.home-manager
    ];
  };
}
