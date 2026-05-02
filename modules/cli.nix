{ self, ... }:
{
  flake.modules.homeManager.cli = {
    imports = [
      self.modules.homeManager.base
      self.modules.homeManager.fish
      self.modules.homeManager.git
      self.modules.homeManager.gpg
      self.modules.homeManager.lazygit
      self.modules.homeManager.nh
      self.modules.homeManager.starship
      self.modules.homeManager.yazi
      self.modules.homeManager.zoxide
    ];
  };
}
