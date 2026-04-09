{
  flake.modules.homeManager.gpg =
    { config, pkgs, ... }:
    {
      programs.gpg = {
        enable = true;
        homedir = "${config.xdg.dataHome}/gnupg";
        mutableKeys = false;
        mutableTrust = false;
        publicKeys = [
          {
            source = ./public.asc;
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
