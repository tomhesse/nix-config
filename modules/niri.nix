{ inputs, ... }:
{
  flake-file.inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      nixpkgs-stable.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };

      niri-flake.cache.enable = false;

      programs.uwsm = {
        enable = true;
        waylandCompositors.niri = {
          prettyName = "Niri";
          comment = "Niri managed by UWSM";
          binPath = "/run/current-system/sw/bin/niri-session";
        };
      };
    };

  flake.modules.homeManager.niri =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        concatMap
        elemAt
        getExe
        getExe'
        listToAttrs
        mapAttrs'
        mod
        nameValuePair
        optionalAttrs
        range
        splitString
        toInt
        ;
      inherit (osConfig) monitors;

      palette =
        (lib.importJSON "${config.catppuccin.sources.palette}/palette.json")
        .${config.catppuccin.flavor}.colors;

      outputId = name: m: if m.description != "" then m.description else name;
      rotation =
        m:
        {
          "normal" = 0;
          "90" = 90;
          "180" = 180;
          "270" = 270;
        }
        .${m.rotation};
      outputs = mapAttrs' (
        name: m:
        let
          res = splitString "x" m.resolution;
        in
        nameValuePair (outputId name m) {
          mode = {
            width = toInt (elemAt res 0);
            height = toInt (elemAt res 1);
            refresh = 1.0 * m.refreshRate;
          };
          position = { inherit (m.position) x y; };
          inherit (m) scale;
          transform.rotation = rotation m;
          focus-at-startup = m.primary;
        }
      ) monitors;

      uwsm = getExe pkgs.uwsm;

      cliphist = getExe pkgs.cliphist;
      kitty = getExe pkgs.kitty;
      media-ctl = getExe pkgs.local.media-ctl;
      playerctl = getExe pkgs.playerctl;
      rofi = getExe pkgs.rofi;
      swaybg = getExe pkgs.swaybg;
      swaylock = getExe config.programs.swaylock.package;
      wl-copy = getExe' pkgs.wl-clipboard "wl-copy";
      xwayland-satellite = getExe pkgs.xwayland-satellite;

      app =
        argv:
        [
          uwsm
          "app"
          "--"
        ]
        ++ argv;

      workspaceBinds = listToAttrs (
        concatMap (
          i:
          let
            key = toString (mod i 10);
          in
          [
            (nameValuePair "Mod+${key}" { action.focus-workspace = i; })
            (nameValuePair "Mod+Shift+${key}" { action.move-column-to-workspace = i; })
          ]
        ) (range 1 10)
      );
    in
    {
      programs.niri.settings = {
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;

        xwayland-satellite.path = xwayland-satellite;

        inherit outputs;

        input = {
          keyboard.xkb.layout = "eu";
          focus-follows-mouse.enable = true;
          touchpad.natural-scroll = false;
          mouse.natural-scroll = false;
        };

        layout = {
          gaps = 10;
          border = {
            enable = true;
            width = 2;
          }
          // optionalAttrs config.catppuccin.enable {
            active.color = palette.${config.catppuccin.accent}.hex;
            inactive.color = palette.surface0.hex;
          };
          focus-ring.enable = false;
          shadow.enable = false;
          default-column-width.proportion = 0.5;
        };

        spawn-at-startup = [
          {
            argv = [
              swaybg
              "-i"
              "${config.wallpaper}"
              "-m"
              "fill"
            ];
          }
        ];

        window-rules = [
          {
            geometry-corner-radius = {
              top-left = 8.0;
              top-right = 8.0;
              bottom-left = 8.0;
              bottom-right = 8.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { is-focused = false; } ];
            opacity = 0.95;
          }
          {
            matches = [ { is-focused = true; } ];
            opacity = 1.0;
          }

          {
            matches = [
              { app-id = "^gamescope$"; }
              { app-id = "^steam_app_"; }
              { app-id = "^Minecraft"; }
              { app-id = "^osu!$"; }
            ];
            open-fullscreen = true;
          }
          {
            matches = [
              { app-id = "^code$"; }
              { app-id = "^firefox$"; }
            ];
            open-maximized = true;
          }

          {
            matches = [
              {
                app-id = "^firefox$";
                title = "^File Upload";
              }
            ];
            open-floating = true;
            default-column-width.proportion = 0.7;
            default-window-height.proportion = 0.7;
          }
          {
            matches = [
              {
                app-id = "^steam$";
                title = "^Friends List$";
              }
              {
                app-id = "^steam$";
                title = "^Sign in to Steam$";
              }
              {
                app-id = "^steam$";
                title = "^Steam Settings$";
              }
            ];
            open-floating = true;
          }
        ];

        binds = {
          "Mod+Shift+Slash".action.show-hotkey-overlay = { };

          "Mod+T".action.spawn = app [ kitty ];
          "Mod+D".action.spawn = app [
            rofi
            "-show"
            "drun"
          ];
          "Mod+V".action.spawn-sh =
            "${cliphist} list | ${uwsm} app -- ${rofi} -dmenu -display-columns 2 | ${cliphist} decode | ${wl-copy}";

          "Mod+Q" = {
            action.close-window = { };
            repeat = false;
          };
          "Mod+F".action.maximize-column = { };
          "Mod+Shift+F".action.fullscreen-window = { };
          "Mod+C".action.center-column = { };
          "Mod+R".action.switch-preset-column-width = { };
          "Mod+Shift+R".action.reset-window-height = { };
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";
          "Mod+Comma".action.consume-window-into-column = { };
          "Mod+Period".action.expel-window-from-column = { };

          "Mod+H".action.focus-column-left = { };
          "Mod+J".action.focus-window-or-workspace-down = { };
          "Mod+K".action.focus-window-or-workspace-up = { };
          "Mod+L".action.focus-column-right = { };
          "Mod+Home".action.focus-column-first = { };
          "Mod+End".action.focus-column-last = { };

          "Mod+Shift+H".action.move-column-left = { };
          "Mod+Shift+J".action.move-window-down-or-to-workspace-down = { };
          "Mod+Shift+K".action.move-window-up-or-to-workspace-up = { };
          "Mod+Shift+L".action.move-column-right = { };
          "Mod+Shift+Home".action.move-column-to-first = { };
          "Mod+Shift+End".action.move-column-to-last = { };

          "Mod+Ctrl+H".action.focus-monitor-left = { };
          "Mod+Ctrl+J".action.focus-monitor-down = { };
          "Mod+Ctrl+K".action.focus-monitor-up = { };
          "Mod+Ctrl+L".action.focus-monitor-right = { };
          "Mod+Ctrl+Shift+H".action.move-column-to-monitor-left = { };
          "Mod+Ctrl+Shift+J".action.move-column-to-monitor-down = { };
          "Mod+Ctrl+Shift+K".action.move-column-to-monitor-up = { };
          "Mod+Ctrl+Shift+L".action.move-column-to-monitor-right = { };

          "Mod+O" = {
            action.toggle-overview = { };
            repeat = false;
          };
          "Mod+U".action.focus-workspace-down = { };
          "Mod+I".action.focus-workspace-up = { };
          "Mod+Shift+U".action.move-column-to-workspace-down = { };
          "Mod+Shift+I".action.move-column-to-workspace-up = { };
          "Mod+Ctrl+U".action.move-workspace-down = { };
          "Mod+Ctrl+I".action.move-workspace-up = { };

          "Print".action.screenshot = { };
          "Ctrl+Print".action.screenshot-screen = { };
          "Alt+Print".action.screenshot-window = { };

          "Mod+Shift+E".action.quit = { };

          "Mod+Alt+L" = {
            action.spawn = app [ swaylock ];
            allow-when-locked = true;
          };

          "XF86AudioMute" = {
            action.spawn = app [
              media-ctl
              "volume"
              "mute"
            ];
            allow-when-locked = true;
          };
          "XF86AudioRaiseVolume" = {
            action.spawn = app [
              media-ctl
              "volume"
              "up"
            ];
            allow-when-locked = true;
          };
          "XF86AudioLowerVolume" = {
            action.spawn = app [
              media-ctl
              "volume"
              "down"
            ];
            allow-when-locked = true;
          };
          "XF86MonBrightnessUp" = {
            action.spawn = app [
              media-ctl
              "brightness"
              "up"
            ];
            allow-when-locked = true;
          };
          "XF86MonBrightnessDown" = {
            action.spawn = app [
              media-ctl
              "brightness"
              "down"
            ];
            allow-when-locked = true;
          };
          "XF86AudioPlay" = {
            action.spawn = [
              playerctl
              "play-pause"
            ];
            allow-when-locked = true;
          };
          "XF86AudioStop" = {
            action.spawn = [
              playerctl
              "stop"
            ];
            allow-when-locked = true;
          };
          "XF86AudioPrev" = {
            action.spawn = [
              playerctl
              "previous"
            ];
            allow-when-locked = true;
          };
          "XF86AudioNext" = {
            action.spawn = [
              playerctl
              "next"
            ];
            allow-when-locked = true;
          };
        }
        // workspaceBinds;
      };
    };
}
