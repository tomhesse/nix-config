{
  config,
  hostNames,
  lib,
  ...
}:
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
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.ssh = {
    knownHosts = lib.genAttrs hostNames (host: {
      publicKeyFile = ../../hosts/${host}/ssh_host_ed25519_key.pub;
      extraHostNames = [
        "${host}.shrimphouse.xyz"
      ]
      ++ (lib.optional (host == config.networking.hostName) "localhost");
    });
  };
}
