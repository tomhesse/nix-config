{ pkgs, ... }:
{
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

  catppuccin.sddm = {
    font = "Fira Sans";
    fontSize = "12";
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
  };
}
