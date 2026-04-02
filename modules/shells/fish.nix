{
  flake.modules.nixos.fish =
    { config, lib, ... }:
    {
      options.hostSpec.shells.fish.enable = lib.mkEnableOption "fish shell";

      config = lib.mkIf config.hostSpec.shells.fish.enable {
        programs.fish.enable = true;
      };
    };
}
