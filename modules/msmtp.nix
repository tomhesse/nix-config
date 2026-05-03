{
  flake.modules.nixos.msmtp =
    { config, ... }:
    {
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
          from = "${config.networking.hostName}@mail.shrimphouse.xyz";
          user = "608deeb4-b226-44f7-bb38-4354d8029c7e";
          passwordeval = "cat ${config.sops.secrets."services/msmtp/password".path}";
        };
      };

      sops.secrets."services/msmtp/password" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
      };
    };
}
