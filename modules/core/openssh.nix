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

  codebergHostKeys = pkgs.writeText "codeberg-host-keys" ''
    codeberg.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8hZi7K1/2E2uBX8gwPRJAHvRAob+3Sn+y2hxiEhN0buv1igjYFTgFO2qQD8vLfU/HT/P/rqvEeTvaDfY1y/vcvQ8+YuUYyTwE2UaVU5aJv89y6PEZBYycaJCPdGIfZlLMmjilh/Sk8IWSEK6dQr+g686lu5cSWrFW60ixWpHpEVB26eRWin3lKYWSQGMwwKv4LwmW3ouqqs4Z4vsqRFqXJ/eCi3yhpT+nOjljXvZKiYTpYajqUC48IHAxTWugrKe1vXWOPxVXXMQEPsaIRc2hpK+v1LmfB7GnEGvF1UAKnEZbUuiD9PBEeD5a1MZQIzcoPWCrTxipEpuXQ5Tni4mN
    codeberg.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBL2pDxWr18SoiDJCGZ5LmxPygTlPu+cCKSkpqkvCyQzl5xmIMeKNdfdBpfbCGDPoZQghePzFZkKJNR/v9Win3Sc=
    codeberg.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB
  '';

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
    knownHostsFiles = [
      codebergHostKeys
      githubHostKeys
    ];
  };
}
