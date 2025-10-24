{
  programs.firefox.policies = {
    AllowFileSelectionDialogs = true;
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    BlockAboutAddons = true;
    BlockAboutConfig = false;
    BlockAboutProfiles = true;
    BlockAboutSupport = false;
    CaptivePortal = true;
    Containers = {
      Default = [
        {
          name = "Personal";
          icon = "circle";
          color = "blue";
        }
        {
          name = "Social";
          icon = "chill";
          color = "purple";
        }
        {
          name = "Media";
          icon = "vacation";
          color = "orange";
        }
        {
          name = "Testing";
          icon = "fence";
          color = "green";
        }
      ];
    };
    Cookies = {
      Behavior = "reject-tracker";
      BehaviorPrivateBrowsing = "reject-tracker-and-partition-foreign";
      Locked = true;
    };
    DisableAppUpdate = true;
    DisableFeedbackCommands = true;
    DisableFirefoxAccounts = true;
    DisableFirefoxScreenshots = true;
    DisableFirefoxStudies = true;
    DisableFormHistory = true;
    DisableMasterPasswordCreation = true;
    DisablePocket = true;
    DisableProfileImport = true;
    DisableProfileRefresh = true;
    DisableSecurityBypass = {
      InvalidCertificate = true;
      SafeBrowsing = true;
    };
    DisableSetDesktopBackground = true;
    DisableTelemetry = true;
    DNSOverHTTPS = {
      Locked = true;
    };
    DontCheckDefaultBrowser = true;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
      EmailTracking = true;
      SuspectedFingerprinting = true;
    };
    EncryptedMediaExtensions = {
      Enabled = false;
      Locked = true;
    };
    ExtensionUpdate = true;
    FirefoxHome = {
      Search = true;
      TopSites = false;
      SponsoredTopSites = false;
      Highlights = false;
      Pocket = false;
      SponsoredPocket = false;
      Snippets = false;
      Locked = true;
    };
    GenerativeAI = {
      Chatbot = false;
      LinkPreviews = true;
      TabGroups = true;
      Locked = true;
    };
    HardwareAcceleration = true;
    Homepage = {
      Locked = true;
      StartPage = "previous-session";
    };
    HttpsOnlyMode = "force_enabled";
    NetworkPrediction = false;
    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;
    PasswordManagerEnabled = false;
    Permissions = {
      Camera = {
        BlockNewRequests = false;
        Locked = true;
      };
      Microphone = {
        BlockNewRequests = false;
        Locked = true;
      };
      Location = {
        BlockNewRequests = false;
        Locked = true;
      };
      Notifications = {
        BlockNewRequests = false;
        Locked = true;
      };
      Autoplay = {
        BlockNewRequests = false;
        Default = "block-audio-video";
        Locked = true;
      };
      VirtualReality = {
        BlockNewRequests = false;
        Locked = true;
      };
      ScreenShare = {
        BlockNewRequests = false;
        Locked = true;
      };
    };
    PictureInPicture = {
      Enabled = true;
      Locked = true;
    };
    PopupBlocking = {
      Default = true;
      Locked = true;
    };
    PostQuantumKeyAgreementEnabled = true;
    SearchSuggestEnabled = false;
    ShowHomeButton = false;
    SkipTermsOfUse = true;
    TranslateEnabled = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      FeatureRecommendations = false;
      UrlbarInterventions = false;
      SkipOnboarding = true;
      MoreFromMozilla = false;
      FirefoxLabs = false;
      Locked = true;
    };
    VisualSearchEnabled = false;
  };
}
