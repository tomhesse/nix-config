{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland; # TODO: Remove when rofi 2.0.0 is available
    font = "Fira Sans 12";
    extraConfig = {
      run-command = "uwsm app -- {cmd}";
      kb-row-up = "Up,Alt+k";
      kb-row-down = "Down,Alt+j";
    };
  };
}
