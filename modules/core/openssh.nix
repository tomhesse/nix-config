{
  config,
  hostNames,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    fileContents
    genAttrs
    optional
    optionals
    unique
    ;

  inherit (config.hostSpec) hostName;

  domain = "shrimphouse.xyz";

  keyPathFor = host: "${inputs.self}/hosts/${host}/ssh_host_ed25519_key.pub";

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
    knownHosts = genAttrs hostNames (host: {
      publicKey = fileContents (keyPathFor host);
      extraHostNames = unique (
        (optionals (domain != null) [ "${host}.${domain}" ]) ++ (optional (host == hostName) "localhost")
      );
    });
    knownHostsFiles = [ githubHostKeys ];
  };
}
