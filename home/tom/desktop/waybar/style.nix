{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf optionalString;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;

  catppuccinEnabled = config.homeSpec.theme.catppuccin.enable;
in
{
  programs.waybar = mkIf enabled {
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
}
