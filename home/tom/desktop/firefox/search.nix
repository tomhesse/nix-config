{
  config,
  pkgs,
  ...
}:
{
  programs.firefox.profiles.tom.search = {
    force = true;
    default = "ddg";
    privateDefault = "ddg";
    engines =
      let
        inherit (config.home) stateVersion;
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      in
      {
        "DuckDuckGo HTML" = {
          urls = [
            {
              template = "https://html.duckduckgo.com/html";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://duckduckgo.com/favicon.ico";
          definedAliases = [ "@ddgh" ];
        };

        "Kagi" = {
          urls = [
            {
              template = "https://kagi.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://kagi.com/favicon.ico";
          definedAliases = [ "@kagi" ];
        };

        "Nix Packages" = {
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "channel";
                  value = "${stateVersion}";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          inherit icon;
          definedAliases = [ "@np" ];
        };

        "Nix Options" = {
          urls = [
            {
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "channel";
                  value = "${stateVersion}";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          inherit icon;
          definedAliases = [ "@no" ];
        };

        "NixOS Wiki" = {
          urls = [
            {
              template = "https://wiki.nixos.org/w/index.php";
              params = [
                {
                  name = "search";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          inherit icon;
          definedAliases = [ "@nw" ];
        };

        "Home Manager" = {
          urls = [
            {
              template = "https://home-manager-options.extranix.com/";
              params = [
                {
                  name = "release";
                  value = "release-${stateVersion}";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          inherit icon;
          definedAliases = [ "@hm" ];
        };

        "MyNixOS" = {
          urls = [
            {
              template = "https://mynixos.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          inherit icon;
          definedAliases = [ "@mn" ];
        };

        "Noogle" = {
          urls = [
            {
              template = "https://noogle.dev/q";
              params = [
                {
                  name = "term";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          inherit icon;
          definedAliases = [ "@ng" ];
        };

        "GitHub Code" = {
          urls = [
            {
              template = "https://github.com/search";
              params = [
                {
                  name = "type";
                  value = "code";
                }
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://github.com/favicon.ico";
          definedAliases = [ "@ghc" ];
        };

        "GitHub Repositories" = {
          urls = [
            {
              template = "https://github.com/search";
              params = [
                {
                  name = "type";
                  value = "repositories";
                }
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://github.com/favicon.ico";
          definedAliases = [ "@ghr" ];
        };

        google.metaData.hidden = true;
        bing.metaData.hidden = true;
        ecosia.metaData.hidden = true;
        wikipedia.metaData.hidden = true;
        perplexity.metaData.hidden = true;
      };
  };
}
