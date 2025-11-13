{ config, lib, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.hostSpec;
in
{
  options.hostSpec.locale = mkOption {
    type = types.str;
    default = "en_US.UTF-8";
    description = "Default system locale.";
  };

  config.i18n.defaultLocale = cfg.locale;
}
