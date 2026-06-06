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
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      codebergHostKeys = pkgs.writeText "codeberg-host-keys" ''
        codeberg.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8hZi7K1/2E2uBX8gwPRJAHvRAob+3Sn+y2hxiEhN0buv1igjYFTgFO2qQD8vLfU/HT/P/rqvEeTvaDfY1y/vcvQ8+YuUYyTwE2UaVU5aJv89y6PEZBYycaJCPdGIfZlLMmjilh/Sk8IWSEK6dQr+g686lu5cSWrFW60ixWpHpEVB26eRWin3lKYWSQGMwwKv4LwmW3ouqqs4Z4vsqRFqXJ/eCi3yhpT+nOjljXvZKiYTpYajqUC48IHAxTWugrKe1vXWOPxVXXMQEPsaIRc2hpK+v1LmfB7GnEGvF1UAKnEZbUuiD9PBEeD5a1MZQIzcoPWCrTxipEpuXQ5Tni4mN
        codeberg.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBL2pDxWr18SoiDJCGZ5LmxPygTlPu+cCKSkpqkvCyQzl5xmIMeKNdfdBpfbCGDPoZQghePzFZkKJNR/v9Win3Sc=
        codeberg.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB
      '';

      githubHostKeys = pkgs.fetchurl {
        url = "https://api.github.com/meta";
        name = "github-host-keys";
        hash = "sha256-xzrF0EXNKjWdIgK3m1UfsipjhGPV3b5e1ZsbOZiGnIg=";
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
            path = "/persistent/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };

      # The direct /persistent path is used instead of the standard /etc/ssh path
      # because sops reads this key during activation (setupSecrets) before the
      # impermanence bind mount for the file is guaranteed to exist.
      environment.persistCleanup.ignoredPaths = [ "/persistent/etc/ssh" ];

      programs.ssh.knownHosts =
        lib.genAttrs hostsWithKeys (host: {
          publicKey = builtins.readFile (keyPathFor host);
          extraHostNames = [
            "${host}.shrimphouse.xyz"
          ]
          ++ lib.optional (host == config.networking.hostName) "localhost";
        })
        // {
          "codeberg.org".publicKeyFile = codebergHostKeys;
          "github.com".publicKeyFile = githubHostKeys;
          "[u591202.your-storagebox.de]:23" = {
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
            extraHostNames = [ "[u591202-sub1.your-storagebox.de]:23" ];
          };
        };
    };
}
