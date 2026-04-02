{
  flake.modules.nixos.locale =
    { config, lib, ... }:
    {
      options.hostSpec.locale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "The system locale for the host.";
      };

      config.i18n.defaultLocale = config.hostSpec.locale;
    };
}
