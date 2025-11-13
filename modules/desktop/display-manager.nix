{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.hostSpec;
in
{
  config = mkIf cfg.desktop.enable {
    catppuccin.sddm = mkIf cfg.theme.catppuccin.enable {
      inherit (cfg.theme.catppuccin) fontSize;
      font = "Fira Code";
    };

    fonts = mkIf cfg.theme.catppuccin.enable {
      packages = [ pkgs.fira-code ];
    };

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
    };

    environment.persistence."/persist".files = [
      {
        file = "/var/lib/sddm/state.conf";
        parentDirectory = {
          user = "sddm";
          group = "sddm";
          mode = "0750";
        };
      }
    ];
  };
}
