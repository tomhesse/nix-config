{
  flake.modules.nixos.sabnzbd =
    { config, ... }:
    {
      systemd.tmpfiles.rules = [
        "d /var/tmp/sabnzbd 0755 sabnzbd sabnzbd -"
        "d /var/tmp/sabnzbd/complete 0755 sabnzbd sabnzbd -"
        "d /var/tmp/sabnzbd/incomplete 0750 sabnzbd sabnzbd -"
        "a+ /var/tmp/sabnzbd/complete - - - - default:user:radarr:rwX,user:radarr:rwX"
        "a+ /var/tmp/sabnzbd/complete - - - - default:user:sonarr:rwX,user:sonarr:rwX"
      ];

      services = {
        sabnzbd = {
          enable = true;
          secretFiles = [ config.sops.templates."sabnzbd-secrets".path ];
          settings = {
            categories = {
              "*" = {
                name = "*";
                order = 0;
                pp = 3;
                script = "None";
              };
              audio = {
                name = "audio";
                order = 3;
                pp = "";
                priority = -100;
                script = "Default";
              };
              movies = {
                name = "movies";
                order = 1;
                pp = "";
                priority = -100;
                script = "Default";
              };
              software = {
                name = "software";
                order = 4;
                pp = "";
                priority = -100;
                script = "Default";
              };
              tv = {
                name = "tv";
                order = 2;
                pp = "";
                priority = -100;
                script = "Default";
              };
            };
            misc = {
              bandwidth_max = "125M";
              bandwidth_perc = 80;
              cache_limit = "24G";
              complete_dir = "/var/tmp/sabnzbd/complete";
              complete_free = "10G";
              direct_unpack = true;
              download_dir = "/var/tmp/sabnzbd/incomplete";
              download_free = "100G";
              email_account = "608deeb4-b226-44f7-bb38-4354d8029c7e";
              email_endjob = "never";
              email_from = "sabnzbd@mail.shrimphouse.xyz";
              email_server = "smtp.tem.scw.cloud";
              email_to = "arr@shrimphouse.xyz,";
              enable_recursive = true;
              fulldisk_autoresume = true;
              history_limit = 10;
              host_whitelist = "sabnzbd.shrimphouse.xyz,";
              permissions = 775;
            };
            servers."news.eweka.nl" = {
              connections = 50;
              displayname = "news.eweka.nl";
              expire_date = "2027-08-16";
              host = "news.eweka.nl";
              name = "news.eweka.nl";
              username = "4110a8a7db7608de";
            };
          };
        };

        oauth2-proxy.nginx.virtualHosts."sabnzbd.shrimphouse.xyz".allowed_groups = [
          "arr_users@shrimphouse.xyz"
        ];

        nginx.virtualHosts."sabnzbd.shrimphouse.xyz" = {
          useACMEHost = "sabnzbd.shrimphouse.xyz";
          forceSSL = true;

          locations."/".proxyPass = "http://127.0.0.1:8080";
        };
      };

      sops = {
        secrets =
          let
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          in
          {
            "services/sabnzbd/api-key" = { inherit sopsFile; };
            "services/sabnzbd/nzb-key" = { inherit sopsFile; };
            "services/sabnzbd/email-pwd" = { inherit sopsFile; };
            "services/sabnzbd/eweka-password" = { inherit sopsFile; };
          };

        templates."sabnzbd-secrets" = {
          owner = "sabnzbd";
          restartUnits = [ "sabnzbd.service" ];
          content = ''
            [misc]
            api_key = ${config.sops.placeholder."services/sabnzbd/api-key"}
            nzb_key = ${config.sops.placeholder."services/sabnzbd/nzb-key"}
            email_pwd = ${config.sops.placeholder."services/sabnzbd/email-pwd"}

            [servers]
            [[news.eweka.nl]]
            password = ${config.sops.placeholder."services/sabnzbd/eweka-password"}
          '';
        };
      };

      security.acme.certs."sabnzbd.shrimphouse.xyz".group = "nginx";
    };
}
