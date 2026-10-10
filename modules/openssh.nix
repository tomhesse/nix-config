let
  hostsDir = ./hosts;
  hostsDirContents = builtins.readDir hostsDir;
  hostNames = builtins.filter (name: hostsDirContents.${name} == "directory") (
    builtins.attrNames hostsDirContents
  );
  keyPathFor = host: hostsDir + "/${host}/ssh_host_ed25519_key.pub";
  hostsWithKeys = builtins.filter (host: builtins.pathExists (keyPathFor host)) hostNames;
in
{
  flake.modules.nixos.openssh =
    { config, lib, ... }:
    let
      persistent = config.environment.persistence."/persistent".enable;
    in
    {
      services.openssh = {
        enable = true;
        settings = {
          KbdInteractiveAuthentication = false;
          LogLevel = "VERBOSE";
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
        hostKeys = [
          {
            # On an ephemeral root the direct /persistent path is used instead of the
            # standard /etc/ssh one, because sops reads this key during activation
            # (setupSecrets) before the impermanence bind mount for the file is
            # guaranteed to exist. Hosts with a persistent root have no /persistent and
            # no such ordering problem, so they use the stock location.
            path =
              if persistent then "/persistent/etc/ssh/ssh_host_ed25519_key" else "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };

      environment.persistCleanup.ignoredPaths = lib.optional persistent "/persistent/etc/ssh";

      programs.ssh.knownHosts = lib.genAttrs hostsWithKeys (host: {
        publicKey = builtins.readFile (keyPathFor host);
        extraHostNames = [
          "${host}.shrimphouse.xyz"
        ]
        ++ lib.optional (host == config.networking.hostName) "localhost";
      });
    };
}
