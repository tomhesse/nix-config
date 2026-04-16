{
  flake.modules.homeManager.vesktop =
    { config, pkgs, ... }:
    let
      jsonFormat = pkgs.formats.json { };
    in
    {
      programs.vesktop = {
        enable = true;
        settings = {
          discordBranch = "stable";
          tray = true;
          minimizeToTray = true;
          autoStartMinimized = true;
          staticTitle = true;
          hardwareAcceleration = true;
          hardwareVideoAcceleration = true;
          disableMinSize = true;
          arRPC = true;
          appBadge = true;
          clickTrayToShowHide = true;
          enableSplashScreen = true;
          splashTheming = true;
          splashColor = "rgb(203, 166, 247)";
          splashBackground = "rgb(24, 24, 37)";
          spellCheckLanguages = [
            "en"
            "en-US"
            "de-DE"
          ];
        };
        vencord.settings = {
          notifications = {
            timeout = 5000;
            position = "bottom-right";
            useNative = "not-focused";
            logLimit = 50;
          };
          plugins = {
            BetterFolders = {
              enabled = true;
              closeAllFolders = true;
              closeAllHomeButton = true;
              closeOthers = true;
            };
          };
        };
      };

      home.file."${config.xdg.relativeConfigHome}/vesktop/state.json".source =
        jsonFormat.generate "vesktop-state"
          { firstLaunch = true; };

      xdg.autostart.entries = [
        "${pkgs.vesktop}/share/applications/vesktop.desktop"
      ];

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeConfigHome}/vesktop/sessionData"
      ];
    };
}
