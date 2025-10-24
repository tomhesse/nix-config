{ lib, ... }:
{
  programs.firefox.policies = {
    "3rdparty".Extensions = {
      "uBlock0@raymondhill.net" = {
        advancedSettings = [
          [
            "autoCommentFilterTemplate"
            "{{url}}"
          ]
          [
            "autoUpdateDelayAfterLaunch"
            "10"
          ]
          [
            "disableWebAssembly"
            "true"
          ]
          [
            "filterAuthorMode"
            "true"
          ]
          [
            "trustedListPrefixes"
            "-"
          ]
          [
            "updateAssetBypassBrowserCache"
            "true"
          ]
        ];
        adminSettings = rec {
          dynamicFilteringString = lib.concatMapStrings (x: x + "\n") [
            # Default rules
            "behind-the-scene * * noop"
            "behind-the-scene * image noop"
            "behind-the-scene * 3p noop"
            "behind-the-scene * inline-script noop"
            "behind-the-scene * 1p-script noop"
            "behind-the-scene * 3p-script noop"
            "behind-the-scene * 3p-frame noop"
            # Block 3rd party frames
            "* * 3p-frame block"
            # Allow captchas
            "* challenges.cloudflare.com * noop"
            "* www.google.com * noop"
            "* www.gstatic.com * noop"
          ];
          hostnameSwitchesString = lib.concatMapStrings (x: x + "\n") [
            "no-csp-reports: * true"
            "no-large-media: behind-the-scene false"
            "no-scripting: * true" # Disable javascript
            "no-scripting: duckduckgo.com false"
          ];
          selectedFilterLists = [
            # uBlock filters
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            # Ads
            "easylist"
            "adguard-mobile"
            # Privacy
            "easyprivacy"
            "adguard-spyware-url"
            "block-lan"
            # Malware protection, security
            "urlhaus-1"
            # Multipurpose
            "plowe-0"
            "dpollock-0"
            # Cookie notices
            "fanboy-cookiemonster"
            # Social widgets
            "fanboy-social"
            # Annoyances
            "easylist-social"
            "easylist-chat"
            "easylist-newsletters"
            "easylist-notifications"
            "easylist-annoyances"
            "ublock-annoyances"
          ]
          ++ userSettings.importedLists;
          userFilters = lib.concatMapStrings (x: x + "\n") [
            # Block Google Doubleclick & Google Analytics
            "||doubleclick.net^$important"
            "||google-analytics.com^$important"
            # Block social media tracking
            "||facebook.com^$important,third-party"
            "||facebook.net^$important,third-party"
            "||linkedin.com^$important,third-party"
            "||instagram.com^$important,third-party"
            "||tiktok.com^$important,third-party"
            "||twitter.com^$third-party"
            "||x.com^$third-party"
            "||gravatar.com^$important,third-party"
            # Block sign-in prompts
            "||accounts.google.com^$third-party"
            "||appleid.apple.com^$third-party"
            "||appleid.cdn-apple.com^$third-party"
            "@@||accounts.google.com^$domain=youtube.com|chromium.org|gstatic.com|googleusercontent.com"
            "@@||appleid.apple.com^$domain=appleid.cdn-apple.com"
            "@@||appleid.cdn-apple.com^$domain=appleid.apple.com"
            # Allow captchas
            "||challenges.cloudflare.com^$third-party"
            "@@||challenges.cloudflare.com/cdn-cgi/challenge-platform/$third-party,script,frame"
            "||www.google.com^$third-party,subdocument"
            "@@||www.google.com/recaptcha/$third-party,subdocument"
            "||www.gstatic.com^$third-party,script"
            "@@||www.gstatic.com/recaptcha/$third-party,script"
          ];
          userSettings = rec {
            popupPanelSections = 31;
            prefetchingDisabled = true;
            hyperlinkAuditingDisabled = true;
            cnameUncloakEnabled = true;
            uiTheme = "auto";
            uiAccentCustom = true;
            uiAccentCustom0 = "#cba6f7";
            advancedUserEnabled = true;
            autoUpdate = true;
            suspendUntilListsAreLoaded = true;
            parseAllABPHideFilters = true;
            ignoreGenericCosmeticFilters = false;
            importedLists = [
              # Privacy
              "https://gitlab.com/DandelionSprout/adfilt/-/raw/master/LegitimateURLShortener.txt"
              "https://raw.githubusercontent.com/yokoffing/filterlists/main/block_third_party_fonts.txt"
              "https://raw.githubusercontent.com/yokoffing/filterlists/main/click2load.txt"
              # Malware protection, security
              "https://badblock.celenity.dev/abp/unsafe.txt"
              "https://gitlab.com/DandelionSprout/adfilt/-/raw/master/Dandelion%20Sprout's%20Anti-Malware%20List.txt"
              "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/dyndns.txt"
              "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/tif.mini.txt"
              "https://raw.githubusercontent.com/fmhy/FMHYFilterlist/main/filterlist-basic.txt"
              # Multipurpose
              "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/ultimate.mini.txt"
              # Additional
              "https://badblock.celenity.dev/abp/badblock.txt"
            ];
            externalLists = lib.concatStringsSep "\n" importedLists;
          };
        };
      };
    };
    ExtensionSettings = {
      "*" = {
        installation_mode = "blocked";
        blocked_install_message = "Addon is not added in the nix config";
      };

      # Themes
      # Catppuccin Mocha - Mauve
      "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-mauve-git/latest.xpi";
      };

      # Extensions
      # Bitwarden Password Manager
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        private_browsing = true;
      };

      # Firefox Multi-Account Containers
      "@testpilot-containers" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
      };

      # Queryamoid
      "queryamoid@kaply.com" = {
        installation_mode = "force_installed";
        install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.2/query_amo_addon_id-0.2-fx.xpi";
      };

      # uBlock Origin
      "uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        private_browsing = true;
      };
    };
  };
}
