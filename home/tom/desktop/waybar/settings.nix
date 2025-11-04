{ pkgs, ... }:
let
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = with pkgs; [
      gawk
      systemd
      uwsm
      rofi-wayland # TODO: Change to rofi when rofi 2.0.0 is available
    ];
    text = ''
      choice="$(
        printf '%s\n' \
          '  Shutdown' \
          '  Reboot' \
          '  Suspend' \
          '  Logout' \
          '  Lock' \
        | rofi -dmenu -i -p 'Power Menu' | awk '{print $2}'
      )"

      case "$choice" in
        Shutdown)
          exec systemctl poweroff ;;
        Reboot)
          exec systemctl reboot ;;
        Suspend)
          exec systemctl suspend ;;
        Lock)
          exec hyprlock ;;
        Logout)
          exec uwsm stop ;;
        *)
          exit 0 ;;
      esac
    '';
  };
in
{
  home.packages = [ powerMenu ];

  programs.waybar.settings = {
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
        on-click = "${powerMenu}/bin/power-menu";
      };

      memory = {
        format = " {used:0.1f}G";
        tooltip = false;
      };

      mpris = {
        format = "{player_icon} {title} - {artist}";
        format-paused = "{status_icon} {title} - {artist}";

        player-icons = {
          default = "󰝚";
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
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-scroll-up = "${pkgs.local.dunst-scripts}/bin/volume-up";
        on-scroll-down = "${pkgs.local.dunst-scripts}/bin/volume-down";
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
          "zsh" = " Terminal";
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
          "5" = "󰊴";
          "6" = "";
        };
        persistent-workspaces = {
          "*" = 5;
        };
        show-special = true;
      };
    };
  };
}
