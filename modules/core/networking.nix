{
  config,
  hostNameFromDir,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;

  cfg = config.hostSpec;
in
{
  options.hostSpec.hostName = mkOption {
    type = types.str;
    default = hostNameFromDir;
    description = "Short hostname of the machine (without domain).";
  };

  config.networking = {
    inherit (cfg) hostName;
  };
}
