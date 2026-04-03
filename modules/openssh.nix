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
      cfg = config.hostSpec.impermanence;
      hostKeyPath =
        if cfg.enable then "/persistent/etc/ssh/ssh_host_ed25519_key" else "/etc/ssh/ssh_host_ed25519_key";
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
            path = hostKeyPath;
            type = "ed25519";
          }
        ];
      };

      programs.ssh.knownHosts = lib.genAttrs hostsWithKeys (host: {
        publicKey = builtins.readFile (keyPathFor host);
        extraHostNames = lib.optional (host == config.networking.hostName) "localhost";
      });
    };
}
