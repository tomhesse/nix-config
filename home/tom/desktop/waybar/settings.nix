{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) getExe getExe' mkIf;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;

  uwsm = getExe pkgs.uwsm;

  power-menu = getExe pkgs.local.power-menu;

  rofi-bluetooth = getExe pkgs.rofi-bluetooth;

  pavucontrol = getExe pkgs.pavucontrol;
  volume-up = getExe' pkgs.local.dunst-scripts "volume-up";
  volume-down = getExe' pkgs.local.dunst-scripts "volume-down";
in
{
  programs.waybar = mkIf enabled {
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
          on-scroll-up = "${uwsm} app -- ${volume-up}";
          on-scroll-down = "${uwsm} app -- ${volume-down}";
          tooltip = false;
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };

        "hyprland/window" = {
          format = "{}";
          rewrite = {
            "" = " Hyprland";
            "~" = " Terminal";
            "fish" = " Terminal";
            "kitty" = " Terminal";

            "tmux(.*)" = " Tmux";

            "nvim" = " Neovim";
            "nvim (.*)" = " $1";

            "(.*)Mozilla Firefox" = "󰈹 Firefox";
            "(.*) — Mozilla Firefox" = "󰈹 $1";

            "(.*)Discord(.*)" = " $1Discord$2";
            "vesktop" = " Discord";
          };
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            default = "";
            special = "";
            urgent = "";
          };
          show-special = true;
        };
      };
    };
  };
}
