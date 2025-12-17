{
  homeSpec = {
    browser.firefox.enable = true;
    monitors = [
      {
        name = "eDP-1";
        primary = true;
        width = 2880;
        height = 1920;
        refreshRate = 120;
        scale = 2.0;
        defaultWorkspace = "1";
        workspaces = [
          "1"
          "2"
          "3"
          "4"
          "5"
        ];
      }
    ];
  };
}
