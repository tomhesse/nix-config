{
  flake.modules.nixos.acme =
    { config, ... }:
    {
      security.acme = {
        acceptTerms = true;

        defaults = {
          email = "hostmaster@shrimphouse.xyz";
          dnsProvider = "scaleway";
          credentialFiles."SCW_SECRET_KEY_FILE" =
            config.sops.secrets."services/acme/scaleway-secret-key".path;
        };
      };

      sops.secrets."services/acme/scaleway-secret-key" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
      };

      environment.persistence."/persistent".directories = [
        "/var/lib/acme"
      ];
    };
}
