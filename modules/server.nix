{ self, ... }:
{
  flake.modules.nixos.server = {
    imports = [
      self.modules.nixos.acme
      self.modules.nixos.base
      self.modules.nixos.lts-kernel
      self.modules.nixos.nginx
      self.modules.nixos.zfs
    ];
  };

  flake.modules.homeManager.server = {
    imports = [
      self.modules.homeManager.base
    ];
  };
}
