{
  programs.firefox.profiles.tom.settings = {
    # General settings
    "intl.accept_languages" = "en-US, en, de-de";
    "browser.aboutConfig.showWarning" = false;
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.tabs.closeWindowWithLastTab" = false;
    "browser.translations.neverTranslateLanguages" = "de";
    "privacy.clearOnShutdown.history" = false;
    "browser.tabs.crashReporting.sendReport" = false;

    # Privacy
    "media.peerconnection.enabled" = false; # Disable WebRTC
    "privacy.resistFingerprinting" = false;
    "browser.send_pings" = false;
    "privacy.bounceTrackingProtection.mode" = 1;
    "network.http.referer.XOriginPolicy" = 2;
    "network.http.referer.XOriginTrimmingPolicy" = 2;
    "privacy.firstparty.isolate" = true;
    "beacon.enabled" = false;
    "dom.event.clipboardevents.enabled" = false;
    "dom.battery.enabled" = false;
    "geo.enabled" = false;
    "media.navigator.enabled" = false;
    "privacy.globalprivacycontrol.enabled" = true;

    # Sidebar & vertical tabs
    "sidebar.main.tools" = "history,bookmarks";
    "sidebar.revamp" = true;
    "sidebar.verticalTabs" = true;
    "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
    "sidebar.visibility" = "always-show";

    # Layout
    "browser.uiCustomization.state" = builtins.toJSON {
      currentVersion = 23;
      newElementCount = 10;
      dirtyAreaCache = [
        "nav-bar"
        "PersonalToolbar"
        "toolbar-menubar"
        "TabsToolbar"
        "widget-overflow-fixed-list"
        "vertical-tabs"
      ];
      placements = {
        PersonalToolbar = [ "personal-bookmarks" ];
        vertical-tabs = [ "tabbrowser-tabs" ];
        toolbar-menubar = [ "menubar-items" ];
        widget-overflow-fixed-list = [ ];
        TabsToolbar = [ ];
        nav-bar = [
          "sidebar-button"
          "back-button"
          "forward-button"
          "vertical-spacer"
          "stop-reload-button"
          "urlbar-container"
          "downloads-button"
          "ublock0_raymondhill_net-browser-action"
          "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
          "_testpilot-containers-browser-action"
          "unified-extensions-button"
        ];
        unified-extensions-area = [
          "queryamoid_kaply_com-browser-action"
        ];
      };
      seen = [
        "ublock0_raymondhill_net-browser-action"
        "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
        "_testpilot-containers-browser-action"
        "queryamoid_kaply_com-browser-action"
        "developer-button"
      ];
    };
  };
}
