{
  flake.modules.homeManager.rofi = {
    programs.rofi = {
      enable = true;
      font = "Fira Sans 12";
      extraConfig = {
        run-command = "uwsm app -- {cmd}";
        kb-row-up = "Up,Alt+k";
        kb-row-down = "Down,Alt+j";
      };
    };
  };
}
