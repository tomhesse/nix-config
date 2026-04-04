{
  flake.modules.nixos.yubikey = {
    programs.yubikey-manager.enable = true;
  };
}
