{ config, lib, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.hostSpec;
in
{
  options.hostSpec.timeZone = mkOption {
    type = types.str;
    default = "UTC";
    description = "Timezone of the system.";
  };

  config.time.timeZone = cfg.timeZone;
}
