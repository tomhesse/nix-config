{
  flake.modules.nixos.kanidm =
    { config, pkgs, ... }:
    let
      certDir = config.security.acme.certs."idm.shrimphouse.xyz".directory;
    in
    {
      services.kanidm = {
        enableServer = true;
        package = pkgs.kanidm_1_9;
        serverSettings = {
          bindaddress = "[::1]:8443";
          db_fs_type = "zfs";
          domain = "shrimphouse.xyz";
          origin = "https://idm.shrimphouse.xyz";
          tls_chain = "${certDir}/fullchain.pem";
          tls_key = "${certDir}/key.pem";
          online_backup.versions = 0;
        };
      };

      security.acme.certs."idm.shrimphouse.xyz" = {
        group = "kanidm";
        postRun = "systemctl reload-or-restart kanidm.service";
      };

      users.users.nginx.extraGroups = [ "kanidm" ];

      services.nginx.virtualHosts."idm.shrimphouse.xyz" = {
        useACMEHost = "idm.shrimphouse.xyz";
        forceSSL = true;
        locations."/".proxyPass = "https://[::1]:8443";
      };
    };

  flake.modules.nixos.kanidm-client =
    { pkgs, ... }:
    {
      services.kanidm = {
        enableClient = true;
        clientSettings.uri = "https://idm.shrimphouse.xyz";
        package = pkgs.kanidm_1_9;
      };
    };
}
