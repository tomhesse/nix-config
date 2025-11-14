{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  enabled = config.homeSpec.browser.firefox.enable;

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;
in
{
  options.homeSpec.browser.firefox.enable =
    mkEnableOption "Enable firefox in this home-manager config.";

  config = mkIf enabled {
    programs.firefox = {
      enable = true;
      languagePacks = [ "en-US" ];
    };

    home.persistence = mkIf impermanenceEnabled {
      "/persist${config.home.homeDirectory}" = {
        directories = [
          ".mozilla/firefox"
        ];
      };
    };
  };
}
