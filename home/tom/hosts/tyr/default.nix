{
  homeSpec = {
    browser.firefox.enable = true;
    gaming.steam.autostart = true;
    monitors = [
      {
        name = "DP-1";
        primary = true;
        width = 2560;
        height = 1440;
        refreshRate = 144;
        workspaces = [
          "1"
          "2"
          "3"
        ];
      }
      {
        name = "HDMI-A-1";
        width = 1920;
        height = 1080;
        position = "auto-left";
        rotation = 1;
        workspaces = [
          "4"
          "5"
          "6"
        ];
      }
      {
        name = "DP-2";
        width = 1920;
        height = 1080;
        position = "auto-right";
        workspaces = [
          "7"
          "8"
          "9"
        ];
      }
    ];
  };
}
