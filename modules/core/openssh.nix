{
  config,
  hostNames,
  lib,
  pkgs,
  ...
}:
let
  githubHostKeys = pkgs.fetchurl {
    url = "https://api.github.com/meta";
    name = "github-host-keys";
    sha256 = "c73ac5d045cd2a359d2202b79b551fb22a638463d5ddbe5ed59b1b3998869c88";
    downloadToTemp = true;
    postFetch = ''
      ${pkgs.jq}/bin/jq -r '.ssh_keys[] | "github.com " + .' $downloadedFile > $out
    '';
  };
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
    knownHostsFiles = [ githubHostKeys ];
  };
}
