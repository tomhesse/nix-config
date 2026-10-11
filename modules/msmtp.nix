{
  flake.modules.nixos.msmtp =
    { config, lib, ... }:
    let
      inherit (lib) mkOption types;
    in
    {
      options.msmtp = {
        adminAddress = mkOption {
          type = types.str;
          default = "admin@shrimphouse.xyz";
          description = "Recipient of system alerts.";
        };

        senderDomain = mkOption {
          type = types.str;
          default = "mail.shrimphouse.xyz";
          description = "Domain of the sender addresses used for system mail.";
        };
      };

      config = {
        programs.msmtp = {
          enable = true;
          setSendmail = true;
          defaults = {
            auth = true;
            tls = true;
            tls_starttls = false;
          };
          accounts.default = {
            host = "smtp.tem.scaleway.com";
            port = 465;
            from = "${config.networking.hostName}@${config.msmtp.senderDomain}";
            user = "608deeb4-b226-44f7-bb38-4354d8029c7e";
            passwordeval = "/run/current-system/sw/bin/cat ${
              config.sops.secrets."services/msmtp/password".path
            }";
          };
        };

        sops.secrets."services/msmtp/password" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };
      };
    };
}
