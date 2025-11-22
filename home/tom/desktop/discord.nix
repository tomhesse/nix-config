{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  jsonFormat = pkgs.formats.json { };

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  cfg = config.homeSpec.desktop.discord;

  relativeConfigHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome;
in
{
  options.homeSpec.desktop.discord.autostart = mkEnableOption "Autostart discord on loin.";

  config = {
    programs.vesktop = {
      enable = true;
      settings = {
        discordBranch = "stable";
        tray = true;
        minimizeToTray = true;
        autoStartMinimized = true;
        hardwareAcceleration = true;
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
      vencord = {
        settings = {
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
        useSystem = true;
      };
    };

    home.file."${relativeConfigHome}/vesktop/state.json".source = jsonFormat.generate "vesktop-state" {
      firstLaunch = true;
    };

    xdg.autostart.entries = mkIf cfg.autostart [
      "${pkgs.vesktop}/share/applications/vesktop.desktop"
    ];

    home.persistence = mkIf impermanenceEnabled {
      "/persist${config.home.homeDirectory}" = {
        directories = [
          "${relativeConfigHome}/vesktop/sessionData"
        ];
      };
    };
  };
}
