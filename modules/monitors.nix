{
  flake.modules.nixos.monitors =
    { config, lib, ... }:
    let
      inherit (lib)
        attrValues
        count
        elem
        mapAttrsToList
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
      ]
      ++ mapAttrsToList (name: m: {
        assertion = m.defaultWorkspace == null || elem m.defaultWorkspace m.workspaces;
        message = "Monitor ${name}: defaultWorkspace ${toString m.defaultWorkspace} must be in its workspaces list.";
      }) config.monitors;

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
                type = types.ints.positive;
                default = 60;
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
              workspaces = mkOption {
                type = types.listOf types.int;
                default = [ ];
                example = [
                  1
                  2
                  3
                ];
                description = "Workspaces to pin to this monitor. Hyprland only; niri workspaces are dynamic.";
              };
              defaultWorkspace = mkOption {
                type = types.nullOr types.int;
                default = null;
                example = 1;
                description = "Default workspace to open on this monitor. Hyprland only; niri uses `primary` instead.";
              };
              namedWorkspaces = mkOption {
                type = types.listOf types.str;
                default = [ ];
                example = [
                  "gaming"
                  "launcher"
                ];
                description = "Named workspaces to pin to this monitor.";
              };
            };
          }
        );
        default = { };
      };
    };
}
