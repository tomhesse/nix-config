{
  flake.modules.nixos.networking =
    { config, lib, ... }:
    {
      options.hostSpec.hostName = lib.mkOption {
        type = lib.types.str;
        description = "The hostname for the host.";
      };

      config.networking.hostName = config.hostSpec.hostName;
    };
}
