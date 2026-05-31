{
  flake.modules.nixos.hyprland = {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
  };

  flake.modules.homeManager.hyprland =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        concatLists
        getExe
        getExe'
        mapAttrsToList
        ;
      inherit (lib.generators) mkLuaInline;
      inherit (osConfig) monitors;

      monitorId = name: m: if m.description != "" then "desc:${m.description}" else name;
      transform =
        m:
        {
          "normal" = 0;
          "90" = 1;
          "180" = 2;
          "270" = 3;
        }
        .${m.rotation};
      monitorAttrs = mapAttrsToList (name: m: {
        output = monitorId name m;
        mode = "${m.resolution}@${toString m.refreshRate}";
        position = "${toString m.position.x}x${toString m.position.y}";
        inherit (m) scale;
        transform = transform m;
      }) monitors;
      workspaceRules = concatLists (
        mapAttrsToList (
          name: m:
          map (
            ws:
            {
              workspace = toString ws;
              monitor = monitorId name m;
            }
            // lib.optionalAttrs (m.defaultWorkspace == ws) { default = true; }
          ) m.workspaces
        ) monitors
      );

      uwsm = getExe pkgs.uwsm;

      cliphist = getExe pkgs.cliphist;
      hyprlock = getExe pkgs.hyprlock;
      kitty = getExe pkgs.kitty;
      media-ctl = getExe pkgs.local.media-ctl;
      playerctl = getExe pkgs.playerctl;
      power-menu = getExe pkgs.local.power-menu;
      rofi = getExe pkgs.rofi;
      wl-copy = getExe' pkgs.wl-clipboard "wl-copy";

      mkBind = keys: dsp: {
        _args = [
          keys
          dsp
        ];
      };
      mkBindF = keys: dsp: flags: {
        _args = [
          keys
          dsp
          flags
        ];
      };

      dsp = {
        exec = cmd: mkLuaInline ''hl.dsp.exec_cmd("${cmd}")'';
        close = mkLuaInline "hl.dsp.window.close()";
        float = mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'';
        fullscreen = mkLuaInline "hl.dsp.window.fullscreen()";
        drag = mkLuaInline "hl.dsp.window.drag()";
        resize = mkLuaInline "hl.dsp.window.resize()";
        layout = msg: mkLuaInline ''hl.dsp.layout("${msg}")'';
        focusWs = ws: mkLuaInline "hl.dsp.focus({ workspace = ${ws} })";
        focusMon = dir: mkLuaInline ''hl.dsp.focus({ monitor = "${dir}" })'';
        moveWs = ws: mkLuaInline "hl.dsp.window.move({ workspace = ${ws} })";
        moveMon = dir: mkLuaInline ''hl.dsp.window.move({ monitor = "${dir}" })'';
        toggleSpecial = name: mkLuaInline ''hl.dsp.workspace.toggle_special("${name}")'';
      };

      mkKey = key: mkLuaInline ''mainMod .. " + ${key}"'';
      mkShiftKey = key: mkLuaInline ''mainMod .. " + SHIFT + ${key}"'';
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          mainMod._var = "SUPER";

          config = {
            decoration = {
              rounding = 8;
              shadow.enabled = false;
            };
            ecosystem = {
              no_update_news = true;
              no_donation_nag = true;
            };
            general = {
              border_size = 2;
              gaps_out = 10;
              layout = "master";
            }
            // lib.optionalAttrs config.catppuccin.enable {
              col = {
                active_border = mkLuaInline "colors.accent";
                inactive_border = mkLuaInline "colors.surface0";
              };
            };
            input = {
              kb_layout = "eu";
              follow_mouse = 1;
            };
            master = {
              new_status = "master";
            };
            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              font_family = "Fira Sans";
            };
          };

          monitor = monitorAttrs ++ [
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = 1;
            }
          ];

          workspace_rule = workspaceRules;

          window_rule = [
            {
              match.focus = false;
              opacity = 0.95;
            }
            {
              match.focus = true;
              opacity = 1.0;
            }

            {
              match.class = "^(firefox)$";
              workspace = "2 silent";
            }
            {
              match.class = "^(dev\\.zed\\.Zed)$";
              workspace = "3 silent";
            }
            {
              match.class = "^(vesktop)$";
              workspace = "5 silent";
            }
            {
              match.class = "^(gamescope)$";
              workspace = 10;
              fullscreen = true;
            }
            {
              match.class = "^(steam_app_)";
              workspace = 10;
              fullscreen = true;
            }
            {
              match.initial_class = "^(Minecraft.*)";
              workspace = 10;
              fullscreen = true;
            }
            {
              match.class = "^(org\\.prismlauncher\\.PrismLauncher)$";
              workspace = "name:gaming";
            }
            {
              match.class = "^(steam)$";
              workspace = "name:gaming";
            }
            {
              match.class = "^(feishin)$";
              workspace = "special:music";
            }
            {
              match.class = "^(obsidian)$";
              workspace = "special:notes silent";
            }

            {
              match = {
                class = "^(firefox)$";
                title = "^(File Upload)";
              };
              float = true;
              size = "50% 50%";
              maxsize = "50% 50%";
              center = true;
            }
            {
              match = {
                class = "^(kitty)$";
                title = "^(termfilechooser)$";
              };
              float = true;
              size = "70% 70%";
              center = true;
            }
            {
              match = {
                class = "^(steam)$";
                title = "^(Friends List)$";
              };
              float = true;
              center = true;
            }
            {
              match = {
                class = "^(steam)$";
                title = "^(Sign in to Steam)$";
              };
              float = true;
              center = true;
            }
            {
              match = {
                class = "^(steam)$";
                title = "^(Steam Settings)$";
              };
              float = true;
              center = true;
            }
          ];

          bind = [
            # Application launchers
            (mkBind (mkKey "V") (
              dsp.exec "${cliphist} list | ${uwsm} app -- ${rofi} -dmenu -display-columns 2 | ${cliphist} decode | ${wl-copy}"
            ))
            (mkBind (mkShiftKey "L") (dsp.exec "${uwsm} app -- ${hyprlock}"))
            (mkBind (mkKey "P") (dsp.exec "${uwsm} app -- ${rofi} -show drun"))
            (mkBind (mkShiftKey "P") (dsp.exec "${uwsm} app -- ${power-menu}"))
            (mkBind (mkShiftKey "RETURN") (dsp.exec "${uwsm} app -- ${kitty}"))

            (mkBind "Print" (dsp.exec "hyprshot -m region"))

            # Workspace navigation
            (mkBind (mkKey "G") (dsp.focusWs ''"name:gaming"''))
            (mkBind (mkShiftKey "M") (dsp.toggleSpecial "music"))
            (mkBind (mkShiftKey "O") (dsp.toggleSpecial "notes"))

            # Layout messages
            (mkBind (mkKey "J") (dsp.layout "cyclenext"))
            (mkBind (mkKey "K") (dsp.layout "cycleprev"))
            (mkBind (mkKey "I") (dsp.layout "addmaster"))
            (mkBind (mkKey "D") (dsp.layout "removemaster"))
            (mkBind (mkKey "H") (dsp.layout "mfact -0.05"))
            (mkBind (mkKey "L") (dsp.layout "mfact +0.05"))

            (mkBind (mkKey "RETURN") (dsp.layout "swapwithmaster"))

            # Window management
            (mkBind (mkShiftKey "C") dsp.close)
            (mkBind (mkKey "F") dsp.float)
            (mkBind (mkKey "M") dsp.fullscreen)

            # Workspace switching
            (mkBind (mkKey "1") (dsp.focusWs "1"))
            (mkBind (mkKey "2") (dsp.focusWs "2"))
            (mkBind (mkKey "3") (dsp.focusWs "3"))
            (mkBind (mkKey "4") (dsp.focusWs "4"))
            (mkBind (mkKey "5") (dsp.focusWs "5"))
            (mkBind (mkKey "6") (dsp.focusWs "6"))
            (mkBind (mkKey "7") (dsp.focusWs "7"))
            (mkBind (mkKey "8") (dsp.focusWs "8"))
            (mkBind (mkKey "9") (dsp.focusWs "9"))
            (mkBind (mkKey "0") (dsp.focusWs "10"))
            (mkBind (mkKey "TAB") (dsp.focusWs ''"previous"''))

            # Move window to workspace
            (mkBind (mkShiftKey "1") (dsp.moveWs "1"))
            (mkBind (mkShiftKey "2") (dsp.moveWs "2"))
            (mkBind (mkShiftKey "3") (dsp.moveWs "3"))
            (mkBind (mkShiftKey "4") (dsp.moveWs "4"))
            (mkBind (mkShiftKey "5") (dsp.moveWs "5"))
            (mkBind (mkShiftKey "6") (dsp.moveWs "6"))
            (mkBind (mkShiftKey "7") (dsp.moveWs "7"))
            (mkBind (mkShiftKey "8") (dsp.moveWs "8"))
            (mkBind (mkShiftKey "9") (dsp.moveWs "9"))
            (mkBind (mkShiftKey "0") (dsp.moveWs "10"))

            # Monitor navigation
            (mkBind (mkKey "COMMA") (dsp.focusMon "-1"))
            (mkBind (mkKey "PERIOD") (dsp.focusMon "+1"))
            (mkBind (mkShiftKey "COMMA") (dsp.moveMon "-1"))
            (mkBind (mkShiftKey "PERIOD") (dsp.moveMon "+1"))

            # Mouse bindings
            (mkBindF (mkKey "mouse:272") dsp.drag { mouse = true; })
            (mkBindF (mkKey "mouse:273") dsp.resize { mouse = true; })

            # Media keys (locked)
            (mkBindF "XF86AudioMute" (dsp.exec "${uwsm} app -- ${media-ctl} volume mute") { locked = true; })
            (mkBindF "XF86AudioPlay" (dsp.exec "${playerctl} play-pause") { locked = true; })
            (mkBindF "XF86AudioStop" (dsp.exec "${playerctl} stop") { locked = true; })
            (mkBindF "XF86AudioPrev" (dsp.exec "${playerctl} previous") { locked = true; })
            (mkBindF "XF86AudioNext" (dsp.exec "${playerctl} next") { locked = true; })

            # Media keys (locked + repeating)
            (mkBindF "XF86AudioRaiseVolume" (dsp.exec "${uwsm} app -- ${media-ctl} volume up") {
              locked = true;
              repeating = true;
            })
            (mkBindF "XF86AudioLowerVolume" (dsp.exec "${uwsm} app -- ${media-ctl} volume down") {
              locked = true;
              repeating = true;
            })
            (mkBindF "XF86MonBrightnessUp" (dsp.exec "${uwsm} app -- ${media-ctl} brightness up") {
              locked = true;
              repeating = true;
            })
            (mkBindF "XF86MonBrightnessDown" (dsp.exec "${uwsm} app -- ${media-ctl} brightness down") {
              locked = true;
              repeating = true;
            })
          ];
        };
      };
    };
}
