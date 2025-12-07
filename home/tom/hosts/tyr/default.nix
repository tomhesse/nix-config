{
  homeSpec = {
    browser.firefox.enable = true;
    monitors = [
      {
        name = "DP-2";
        primary = true;
        width = 2560;
        height = 1440;
        refreshRate = 144;
      }
      {
        name = "";
        enabled = false;
      }
    ];
  };
}
