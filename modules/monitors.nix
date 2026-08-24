{
  flake.modules.nixos.monitors =
    { config, lib, ... }:
    let
      inherit (lib)
        attrValues
        count
        mkOption
        types
        ;
      primaryCount = count (m: m.primary) (attrValues config.monitors);
    in
    {
      config.assertions = [
        {
          assertion = primaryCount <= 1;
          message = "At most one monitor may be set as primary, but ${toString primaryCount} are.";
        }
      ];

      options.monitors = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              description = mkOption {
                type = types.str;
                default = "";
                example = "Samsung Electric Company LS27A800U HCJW300042";
              };
              resolution = mkOption {
                type = types.str;
                example = "2560x1440";
              };
              refreshRate = mkOption {
                type = types.numbers.positive;
                default = 60;
                description = ''
                  Refresh rate in Hz. niri requires this to match a mode reported by
                  `niri msg outputs` exactly, to three decimals, so a fractional value
                  may be needed (e.g. 143.998).
                '';
              };
              position = {
                x = mkOption {
                  type = types.int;
                  default = 0;
                };
                y = mkOption {
                  type = types.int;
                  default = 0;
                };
              };
              rotation = mkOption {
                type = types.enum [
                  "normal"
                  "90"
                  "180"
                  "270"
                ];
                default = "normal";
              };
              scale = mkOption {
                type = types.number;
                default = 1.0;
              };
              primary = mkOption {
                type = types.bool;
                default = false;
              };
            };
          }
        );
        default = { };
      };
    };
}
