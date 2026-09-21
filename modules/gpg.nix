{
  flake.modules.homeManager.gpg =
    { config, pkgs, ... }:
    let
      tomhessePublicKey = ./users/thesse/gpg.asc;
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
