{ self, ... }:
{
  flake.modules.nixos.server = {
    imports = [
      self.modules.nixos.base
      self.modules.nixos.lts-kernel
      self.modules.nixos.zfs
    ];
  };
}
