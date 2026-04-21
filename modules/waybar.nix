{
  flake.modules.homeManager.waybar =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe optionalString;

      uwsm = getExe pkgs.uwsm;

      media-ctl = getExe pkgs.local.media-ctl;
      pavucontrol = getExe pkgs.pavucontrol;
      power-menu = getExe pkgs.local.power-menu;
      rofi-bluetooth = getExe pkgs.rofi-bluetooth;

      catppuccinEnabled = config.catppuccin.enable;
    in
    {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings = {
          mainBar = {
            modules-left = [
              "hyprland/workspaces"
              "hyprland/window"
            ];
            modules-center = [
              "clock"
            ];
            modules-right = [
              "mpris"
              "cpu"
              "memory"
              "pulseaudio"
              "battery"
              "bluetooth"
              "network"
              "power-profiles-daemon"
              "tray"
              "custom/power-menu"
            ];

            battery = {
              format = "{icon} {capacity}%";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
            };

            bluetooth = {
              format-on = "󰂯";
              format-off = "󰂲";
              format-disabled = "";
              format-connected = "󰂱 {num_connections}";
              format-no-controller = "";
              tooltip-format = "{controller_alias}\t{controller_address}";
              tooltip-format-connected = "{device_enumerate}";
              tooltip-format-enumerate-connected = "{device_alias}";
              tooltip-format-enumerate-connected-battery = "{device_alias} {device_battery_percentage}% ";
              on-click = "${uwsm} app -- ${rofi-bluetooth}";
            };

            clock = {
              format = "󰥔 {:%H:%M | %a %d.%m.%Y}";
              tooltip-format = "{calendar}";
            };

            cpu = {
              format = "󰍛 {usage}%";
            };

            "custom/power-menu" = {
              format = " ";
              tooltip = false;
              on-click = "${uwsm} app -- ${power-menu}";
            };

            memory = {
              format = " {used:0.1f}G";
              tooltip = false;
            };

            mpris = {
              format = "{player_icon} {title} - {artist}";
              format-paused = "{status_icon} {title} - {artist}";

              player-icons = {
                default = "▶";
                mpd = "󰝚";
              };
              status-icons = {
                paused = "󰏤";
              };

              tooltip-format = "Playing: {title} - {artist}";
              tooltip-format-paused = "Paused: {title} - {artist}";
              min-length = 5;
              max-length = 35;
            };

            network = {
              format-ethernet = "󰈀";
              format-wifi = "󰖩";
              format-disconnected = "󰪎";
              tooltip-format-ethernet = "{ipaddress}/{cidr}";
              tooltip-format-wifi = "{essid} ({signalStrength}%) ";
              tooltip-format-disconnected = "Disconnected";
              format-alt = "󰁞 {bandwidthUpBits} 󰁆 {bandwidthDownBits}";
            };

            power-profiles-daemon = {
              format-icons = {
                performance = "";
                balanced = ""; # TODO: Use solid icon
                power-saver = "";
              };
              tooltip = false;
            };

            pulseaudio = {
              format = "{icon} {volume}%";
              format-bluetooth = "{icon} {volume}%";
              format-muted = "󰝟";
              format-icons = {
                default = [
                  ""
                  ""
                  ""
                ];
              };
              on-click = "${uwsm} app -- ${pavucontrol}";
              on-scroll-up = "${uwsm} app -- ${media-ctl} volume up";
              on-scroll-down = "${uwsm} app -- ${media-ctl} volume down";
              tooltip = false;
            };

            tray = {
              icon-size = 16;
              spacing = 8;
            };

            "hyprland/window" = {
              format = "{class}: {title}";
              rewrite = {
                ": " = " Hyprland";
                ".*: ~" = " Terminal";
                ".*: fish" = " Terminal";
                "kitty: .*" = " Terminal";

                ".*: tmux(.*)" = " Tmux";

                ".*: nvim" = " Neovim";
                ".*: nvim (.*)" = " $1";

                ".*: (.*)Mozilla Firefox" = "󰈹 Firefox";
                ".*: (.*) — Mozilla Firefox" = "󰈹 $1";

                ".*: (.*)Discord(.*)" = " $1Discord$2";
                "vesktop: .*" = " Discord";

                ".*: (.*) - Obsidian(.*)" = "󰠮 $1";

                "steam: (.*)" = "󰓓 $1";

                "dev\.zed\.Zed: (.*)" = "Zed: $1"; # TODO: Add nerd font icon
              };
              separate-outputs = true;
              tooltip = false;
            };

            "hyprland/workspaces" = {
              format = "{icon}";
              format-icons = {
                "1" = "";
                "2" = "󰈹";
                "3" = "";
                "5" = "";
                "gaming" = "";
                "music" = "󰝚";
                "notes" = "󰠮";
                active = "";
                default = "";
                urgent = "";
              };
              show-special = true;
            };
          };
        };

        style = ''
          * {
            border: none;
            border-radius: 1px;
            font-family: "FiraCode Nerd Font";
            font-size: 15px;
            font-weight: bold;
            min-height: 0;
          }

          window#waybar {
            background: transparent;
            ${optionalString catppuccinEnabled "color: @text;"}
            ${optionalString (!catppuccinEnabled) "color: #eeeeee;"}
          }

          tooltip {
            ${optionalString catppuccinEnabled "background: @base;"}
            ${optionalString (!catppuccinEnabled) "background: #1a1a1a;"}
            ${optionalString catppuccinEnabled "border: 2px solid @mauve;"}
            ${optionalString (!catppuccinEnabled) "border: 2px solid #d087ff;"}
            border-radius: 8px;
            ${optionalString catppuccinEnabled "color: @text;"}
            ${optionalString (!catppuccinEnabled) "color: #eeeeee;"}
            padding: 5px;
          }

          button:hover {
            background: none;
            box-shadow: none;
            ${optionalString catppuccinEnabled "text-shadow: 0 0 5px @subtext0;"}
            ${optionalString (!catppuccinEnabled) "text-shadow: 0 0 5px #bbbbbb;"}
            transition: color .2s ease, text-shadow .2s ease;
          }

          /* Base modules */
          #battery,
          #bluetooth,
          #clock,
          #cpu,
          #custom-power-menu,
          #memory,
          #mpris,
          #network,
          #power-profiles-daemon,
          #pulseaudio,
          #tray,
          #window,
          #workspaces {
            ${optionalString catppuccinEnabled "background: @base;"}
            ${optionalString (!catppuccinEnabled) "background: #1a1a1a;"}
            border-radius: 8px;
            margin: 5px;
            padding: 1.5px 7px;
          }

          /* Shared strip borders */
          #battery,
          #bluetooth,
          #cpu,
          #custom-power-menu,
          #memory,
          #network,
          #power-profiles-daemon,
          #pulseaudio,
          #tray {
            ${optionalString catppuccinEnabled "border-bottom: 2px solid @surface0;"}
            ${optionalString (!catppuccinEnabled) "border-bottom: 2px solid #2a2a2a;"}
            ${optionalString catppuccinEnabled "border-top: 2px solid @surface0;"}
            ${optionalString (!catppuccinEnabled) "border-top: 2px solid #2a2a2a;"}
          }

          /* Zero side margins for connected modules */
          #battery,
          #bluetooth,
          #cpu,
          #custom-power-menu,
          #memory,
          #network,
          #power-profiles-daemon,
          #pulseaudio,
          #tray {
            margin-left: 0;
            margin-right: 0;
          }

          /* Square-corner modules */
          #battery,
          #bluetooth,
          #memory,
          #network,
          #power-profiles-daemon,
          #pulseaudio,
          #tray {
            border-radius: 0;
          }

          /* Shared transitions (glow-enabled modules) */
          #custom-power-menu,
          #network,
          #power-profiles-daemon,
          #pulseaudio {
            transition: color .2s ease, text-shadow .2s ease;
          }

          /* Unified hover glow */
          #custom-power-menu:hover,
          #network:hover,
          #power-profiles-daemon:hover,
          #pulseaudio:hover {
            text-shadow: 0 0 3px currentColor;
          }

          /* Module specifics */
          #battery {
            ${optionalString catppuccinEnabled "color: @green;"}
            ${optionalString (!catppuccinEnabled) "color: #8ae98a;"}
          }

          #bluetooth {
            ${optionalString catppuccinEnabled "color: @blue;"}
            ${optionalString (!catppuccinEnabled) "color: #5c7aff;"}
          }

          #clock {
            ${optionalString catppuccinEnabled "border: 2px solid @surface0;"}
            ${optionalString (!catppuccinEnabled) "border: 2px solid #2a2a2a;"}
            border-radius: 20px;
          }

          #cpu {
            ${optionalString catppuccinEnabled "border-left: 2px solid @surface0;"}
            ${optionalString (!catppuccinEnabled) "border-left: 2px solid #2a2a2a;"}
            border-radius: 8px 0 0 8px;
            ${optionalString catppuccinEnabled "color: @blue;"}
            ${optionalString (!catppuccinEnabled) "color: #5c7aff;"}
          }

          #custom-power-menu {
            border-radius: 0 20px 20px 0;
            ${optionalString catppuccinEnabled "border-right: 2px solid @surface0;"}
            ${optionalString (!catppuccinEnabled) "border-right: 2px solid #2a2a2a;"}
            ${optionalString catppuccinEnabled "color: @red;"}
            ${optionalString (!catppuccinEnabled) "color: #ff6b6b;"}
            margin-right: 10px;
          }

          #memory {
            ${optionalString catppuccinEnabled "color: @maroon;"}
            ${optionalString (!catppuccinEnabled) "color: #e08a94;"}
          }

          #mpris {
            ${optionalString catppuccinEnabled "border: 2px solid @surface0;"}
            ${optionalString (!catppuccinEnabled) "border: 2px solid #2a2a2a;"}
            border-radius: 20px 8px 8px 20px;
          }

          #pulseaudio {
            ${optionalString catppuccinEnabled "color: @peach;"}
            ${optionalString (!catppuccinEnabled) "color: #ffb080;"}
          }

          #window {
            ${optionalString catppuccinEnabled "border: 2px solid @surface0;"}
            ${optionalString (!catppuccinEnabled) "border: 2px solid #2a2a2a;"}
            border-radius: 8px 20px 20px 8px;
            margin-left: 0;
          }

          #workspaces {
            ${optionalString catppuccinEnabled "border: 2px solid @surface0;"}
            ${optionalString (!catppuccinEnabled) "border: 2px solid #2a2a2a;"}
            border-radius: 20px 8px 8px 20px;
            margin-left: 10px;
          }

          #workspaces button {
            ${optionalString catppuccinEnabled "color: @subtext0;"}
            ${optionalString (!catppuccinEnabled) "color: #bbbbbb;"}
            margin-right: 5px;
            padding-left: 0;
            padding-right: 0;
          }

          #workspaces button.active,
          #workspaces button.urgent {
            ${optionalString catppuccinEnabled "color: @red;"}
            ${optionalString (!catppuccinEnabled) "color: #ff6b6b;"}
          }

          #workspaces button.empty {
            ${optionalString catppuccinEnabled "color: @surface1;"}
            ${optionalString (!catppuccinEnabled) "color: #323232;"}
          }

          #workspaces button.visible {
            ${optionalString catppuccinEnabled "color: @mauve;"}
            ${optionalString (!catppuccinEnabled) "color: #d087ff;"}
          }
        '';
      };
    };
}
