{
  flake.modules.homeManager.gpg =
    { config, pkgs, ... }:
    let
      tomhessePublicKey = pkgs.fetchurl {
        url = "https://keys.openpgp.org/vks/v1/by-fingerprint/1663EC2E7C8C8E95BE959EB3ABF77DD0DF58CFF4";
        name = "tomhesse-gpg-public-key.asc";
        hash = "sha256-hjSt7x5HDSB5nxnCkH342kwGT4qndnfvLjTEQc+lwEc=";
      };
    in
    {
      programs.gpg = {
        enable = true;
        homedir = "${config.xdg.dataHome}/gnupg";
        mutableKeys = false;
        mutableTrust = false;
        publicKeys = [
          {
            source = tomhessePublicKey;
            trust = "ultimate";
          }
        ];
      };

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentry.package = pkgs.pinentry-rofi;
      };

      home.persistence."/persistent".directories = [
        {
          directory = "${config.xdg.relativeDataHome}/gnupg";
          mode = "0700";
        }
      ];

    };
}
