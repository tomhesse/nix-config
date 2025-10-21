{
  programs.waybar.style = ''
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
      color: @text;
    }

    tooltip {
      background: @base;
      border: 2px solid @mauve;
      border-radius: 8px;
      color: @text;
      padding: 5px;
    }

    button:hover {
      background: none;
      box-shadow: none;
      text-shadow: 0 0 5px @subtext0;
      transition: color .2s ease, text-shadow .2s ease;
    }

    /* Base modules */
    #battery,
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
      background: @base;
      border-radius: 8px;
      margin: 5px;
      padding: 1.5px 7px;
    }

    /* Shared strip borders */
    #battery,
    #cpu,
    #custom-power-menu,
    #memory,
    #network,
    #power-profiles-daemon,
    #pulseaudio,
    #tray {
      border-bottom: 2px solid @surface0;
      border-top: 2px solid @surface0;
    }

    /* Zero side margins for connected modules */
    #battery,
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
      color: @green;
    }

    #clock {
      border: 2px solid @surface0;
      border-radius: 20px;
    }

    #cpu {
      border-left: 2px solid @surface0;
      border-radius: 8px 0 0 8px;
      color: @blue;
    }

    #custom-power-menu {
      border-radius: 0 20px 20px 0;
      border-right: 2px solid @surface0;
      color: @red;
      margin-right: 10px;
    }

    #memory {
      color: @maroon;
    }

    #mpris {
      border: 2px solid @surface0;
      border-radius: 20px 8px 8px 20px;
    }

    #pulseaudio {
      color: @peach;
    }

    #window {
      border: 2px solid @surface0;
      border-radius: 8px 20px 20px 8px;
      margin-left: 0;
    }

    #workspaces {
      border: 2px solid @surface0;
      border-radius: 20px 8px 8px 20px;
      margin-left: 10px;
    }

    #workspaces button {
      color: @subtext0;
      margin-right: 5px;
      padding-left: 0;
      padding-right: 0;
    }

    #workspaces button.active,
    #workspaces button.urgent {
      color: @red;
    }

    #workspaces button.empty {
      color: @surface1;
    }

    #workspaces button.visible {
      color: @mauve;
    }
  '';
}
