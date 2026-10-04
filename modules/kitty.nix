{
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      enable = true;

      font.name = "FiraCode Nerd Font";

      keybindings."shift+enter" = "send_text all \\x1b[13;2u";
    };
  };
}
