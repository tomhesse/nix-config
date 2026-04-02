{
  flake.modules.nixos.zram =
    { config, lib, ... }:
    {
      options.hostSpec.zram.enable = lib.mkEnableOption "zram swap";

      config = lib.mkIf config.hostSpec.zram.enable {
        zramSwap.enable = true;
      };
    };
}
