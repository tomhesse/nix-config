{
  flake.modules.nixos.homepage =
    { config, ... }:
    {
      services = {
        homepage-dashboard = {
          enable = true;

          allowedHosts = "homepage.shrimphouse.xyz";

          settings = {
            title = "Shrimphouse Homepage";
            layout."Download Clients" = {
              style = "row";
              columns = 2;
            };
            layout."Media Management" = {
              style = "row";
              columns = 4;
            };
          };

          widgets = [
            {
              resources = {
                cpu = true;
                memory = true;
                uptime = true;
              };
            }
            {
              search = {
                provider = "duckduckgo";
                target = "_blank";
              };
            }
            {
              datetime = {
                format.dateStyle = "long";
                format.timeStyle = "short";
              };
            }
          ];

          environmentFile = config.sops.templates."homepage-env".path;

          services = [
            {
              "Download Clients" = [
                {
                  "Prowlarr" = {
                    href = "https://prowlarr.shrimphouse.xyz";
                    icon = "prowlarr";
                    widget = {
                      type = "prowlarr";
                      url = "http://127.0.0.1:9696";
                      key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
                    };
                  };
                }
                {
                  "SABnzbd" = {
                    href = "https://sabnzbd.shrimphouse.xyz";
                    icon = "sabnzbd";
                    widget = {
                      type = "sabnzbd";
                      url = "http://127.0.0.1:8080";
                      key = "{{HOMEPAGE_VAR_SABNZBD_API_KEY}}";
                    };
                  };
                }
              ];
            }
            {
              "Media Management" = [
                {
                  "Radarr" = {
                    href = "https://radarr.shrimphouse.xyz";
                    icon = "radarr";
                    widget = {
                      type = "radarr";
                      url = "http://127.0.0.1:7878";
                      key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
                    };
                  };
                }
                {
                  "Sonarr" = {
                    href = "https://sonarr.shrimphouse.xyz";
                    icon = "sonarr";
                    widget = {
                      type = "sonarr";
                      url = "http://127.0.0.1:8989";
                      key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                    };
                  };
                }
                {
                  "Bazarr" = {
                    href = "https://bazarr.shrimphouse.xyz";
                    icon = "bazarr";
                    widget = {
                      type = "bazarr";
                      url = "http://127.0.0.1:6767";
                      key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
                    };
                  };
                }
              ];
            }
            {
              "Streaming" = [
                {
                  "Jellyfin" = {
                    href = "https://jellyfin.shrimphouse.xyz";
                    icon = "jellyfin";
                  };
                }
                {
                  "Navidrome" = {
                    href = "https://music.shrimphouse.xyz";
                    icon = "navidrome";
                  };
                }
              ];
            }
            {
              "Utilities" = [
                {
                  "Kanidm" = {
                    href = "https://idm.shrimphouse.xyz";
                    icon = "kanidm";
                  };
                }
                {
                  "Paperless-ngx" = {
                    href = "https://paperless.shrimphouse.xyz";
                    icon = "paperless-ngx";
                  };
                }
                {
                  "Grocy" = {
                    href = "https://grocy.shrimphouse.xyz";
                    icon = "grocy";
                  };
                }
              ];
            }
          ];
        };

        oauth2-proxy.nginx.virtualHosts."homepage.shrimphouse.xyz" = { };

        nginx.virtualHosts."homepage.shrimphouse.xyz" = {
          useACMEHost = "homepage.shrimphouse.xyz";
          forceSSL = true;

          locations."/".proxyPass = "http://127.0.0.1:8082";
        };
      };

      sops = {
        secrets = {
          "services/homepage/bazarr-api-key".sopsFile =
            ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          "services/homepage/prowlarr-api-key".sopsFile =
            ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          "services/homepage/radarr-api-key".sopsFile =
            ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          "services/homepage/sabnzbd-api-key".sopsFile =
            ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          "services/homepage/sonarr-api-key".sopsFile =
            ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };

        templates."homepage-env" = {
          content = ''
            HOMEPAGE_VAR_BAZARR_API_KEY=${config.sops.placeholder."services/homepage/bazarr-api-key"}
            HOMEPAGE_VAR_PROWLARR_API_KEY=${config.sops.placeholder."services/homepage/prowlarr-api-key"}
            HOMEPAGE_VAR_RADARR_API_KEY=${config.sops.placeholder."services/homepage/radarr-api-key"}
            HOMEPAGE_VAR_SABNZBD_API_KEY=${config.sops.placeholder."services/homepage/sabnzbd-api-key"}
            HOMEPAGE_VAR_SONARR_API_KEY=${config.sops.placeholder."services/homepage/sonarr-api-key"}
          '';
          restartUnits = [ "homepage-dashboard.service" ];
        };
      };

      security.acme.certs."homepage.shrimphouse.xyz".group = "nginx";
    };
}
