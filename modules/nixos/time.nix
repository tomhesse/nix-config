{
  flake.modules.nixos.time =
    { config, lib, ... }:
    {
      options.hostSpec.timeZone = lib.mkOption {
        type = lib.types.str;
        default = "UTC";
        description = "The time zone for the host.";
      };

      config.time.timeZone = config.hostSpec.timeZone;
    };
}
