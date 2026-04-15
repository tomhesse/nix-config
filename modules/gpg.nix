{
  flake.modules.homeManager.gpg =
    { config, pkgs, ... }:
    let
      publicKey = pkgs.fetchurl {
        url = "https://keys.openpgp.org/vks/v1/by-fingerprint/1663EC2E7C8C8E95BE959EB3ABF77DD0DF58CFF4";
        sha256 = "0iy0lp7l3i1l5vppfxm7i97hck6sz1yr1hhrkxwj03a73vpssd46";
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
            source = publicKey;
            trust = "ultimate";
          }
        ];
      };

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentry.package = pkgs.pinentry-rofi;
      };
    };
}
