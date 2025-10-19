{ pkgs, ... }:
{
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
