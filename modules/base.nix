{ self, ... }:
{
  flake.modules.nixos.base = {
    imports = [
      self.modules.nixos.local-packages
      self.modules.nixos.boot
      self.modules.nixos.disko
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
      self.modules.homeManager.bat
      self.modules.homeManager.btop
      self.modules.homeManager.eza
      self.modules.homeManager.fd
      self.modules.homeManager.fish
      self.modules.homeManager.fzf
      self.modules.homeManager.git
      self.modules.homeManager.gpg
      self.modules.homeManager.home-manager
      self.modules.homeManager.sops
      self.modules.homeManager.lazygit
      self.modules.homeManager.neovim
      self.modules.homeManager.nh
      self.modules.homeManager.locale
      self.modules.homeManager.ripgrep
      self.modules.homeManager.starship
      self.modules.homeManager.theme
      self.modules.homeManager.tmux
      self.modules.homeManager.xdg
      self.modules.homeManager.yazi
      self.modules.homeManager.zoxide
    ];
  };
}
