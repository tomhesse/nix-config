{ self, ... }:
{
  flake.modules.nixos.server = {
    imports = [
      self.modules.nixos.base
      self.modules.nixos.lts-kernel
      self.modules.nixos.msmtp
    ];
  };

  flake.modules.homeManager.server = {
    imports = [
      self.modules.homeManager.base
    ];
  };
}
