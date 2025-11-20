{ config, lib, ... }:
let
  inherit (lib)
    filter
    length
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.homeSpec.monitors;
in
{
  options.homeSpec.monitors = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            example = "DP-1";
            description = "Monitor output name.";
          };
          primary = mkEnableOption "Whether this monitor is the primary monitor.";
          width = mkOption {
            type = types.int;
            example = 1920;
            description = "Monitor width in pixels.";
          };
          height = mkOption {
            type = types.int;
            example = 1080;
            description = "Monitor height in pixels.";
          };
          refreshRate = mkOption {
            type = types.int;
            default = 60;
            description = "Refresh rate in Hz.";
          };
          position = mkOption {
            type = types.str;
            default = "auto";
            example = "1920x0";
            description = "Monitor position.";
          };
          scale = mkOption {
            type = types.float;
            default = 1.0;
            description = "Scaling factor for HiDPI displays.";
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Whether the monitor is enabled.";
          };
          workspace = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Assigned workspace.";
          };
        };
      }
    );
    default = [ ];
  };

  config = {
    assertions = [
      {
        assertion = ((length cfg) != 0) -> ((length (filter (monitor: monitor.primary) cfg)) == 1);
        message = "There must be exactly one primary monitor.";
      }
    ];
  };
}
