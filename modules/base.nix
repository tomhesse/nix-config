{ self, ... }:
{
  flake.modules.nixos.base = {
    imports = [
      self.modules.nixos.catppuccin
      self.modules.nixos.disko
      self.modules.nixos.bash
      self.modules.nixos.fish
      self.modules.nixos.home-manager
      self.modules.nixos.local-packages
      self.modules.nixos.locale
      self.modules.nixos.networkd
      self.modules.nixos.nix
      self.modules.nixos.nixpkgs
      self.modules.nixos.openssh
      self.modules.nixos.persistence
      # self.modules.nixos.resolved
      self.modules.nixos.sops
      self.modules.nixos.sudo
      self.modules.nixos.time
      self.modules.nixos.users
      self.modules.nixos.zram
    ];
  };

  flake.modules.homeManager.base = {
    imports = [
      self.modules.homeManager.bash
      self.modules.homeManager.bat
      self.modules.homeManager.btop
      self.modules.homeManager.catppuccin
      self.modules.homeManager.eza
      self.modules.homeManager.fd
      self.modules.homeManager.fzf
      self.modules.homeManager.home-manager
      self.modules.homeManager.locale
      self.modules.homeManager.neovim
      self.modules.homeManager.ripgrep
      self.modules.homeManager.sops
      self.modules.homeManager.tmux
      self.modules.homeManager.xdg
    ];
  };
}
