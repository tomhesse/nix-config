{ config, pkgs, ... }:
let
  gpgKeys = builtins.fetchurl {
    url = "https://keys.openpgp.org/vks/v1/by-fingerprint/1663EC2E7C8C8E95BE959EB3ABF77DD0DF58CFF4";
    sha256 = "19inl9rhc6hs7irx867ihv8zxz753fghlyy96d8cy4mm9nyj4xag";
  };
in
{
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    publicKeys = [
      {
        source = gpgKeys;
        trust = 5;
      }
    ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-rofi.override {
      rofi = pkgs.rofi-wayland;
    };
  };
}
