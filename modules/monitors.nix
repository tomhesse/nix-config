{
  flake.modules.nixos.monitors =
    { config, lib, ... }:
    let
      primaryCount = lib.count (m: m.primary) (lib.attrValues config.monitors);
    in
    {
      config.assertions = [
        {
          assertion = primaryCount <= 1;
          message = "At most one monitor may be set as primary, but ${toString primaryCount} are.";
        }
      ]
      ++ lib.mapAttrsToList (name: m: {
        assertion = m.defaultWorkspace == null || lib.elem m.defaultWorkspace m.workspaces;
        message = "Monitor ${name}: defaultWorkspace ${toString m.defaultWorkspace} must be in its workspaces list.";
      }) config.monitors;

      options.monitors = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              description = lib.mkOption {
                type = lib.types.str;
                default = "";
                example = "Samsung Electric Company LS27A800U HCJW300042";
              };
              resolution = lib.mkOption {
                type = lib.types.str;
                example = "2560x1440";
              };
              refreshRate = lib.mkOption {
                type = lib.types.ints.positive;
                default = 60;
              };
              position = {
                x = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                };
                y = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                };
              };
              rotation = lib.mkOption {
                type = lib.types.enum [
                  "normal"
                  "90"
                  "180"
                  "270"
                ];
                default = "normal";
              };
              scale = lib.mkOption {
                type = lib.types.number;
                default = 1.0;
              };
              primary = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
              workspaces = lib.mkOption {
                type = lib.types.listOf lib.types.int;
                default = [ ];
                example = [
                  1
                  2
                  3
                ];
                description = "Workspaces to pin to this monitor.";
              };
              defaultWorkspace = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = null;
                example = 1;
                description = "Default workspace to open on this monitor.";
              };
            };
          }
        );
        default = { };
      };
    };
}
