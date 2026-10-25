{
  flake.modules.homeManager.kitty =
    { config, lib, ... }:
    {
      programs.kitty = {
        enable = true;

        font.name = "FiraCode Nerd Font";

        keybindings."shift+enter" = "send_text all \\x1b[13;2u";
      };

      # Claude Code's "auto" channel detects the terminal, which under tmux resolves to
      # no method at all, so name the terminal that delivers the notification.
      programs.claude-code.settings.preferredNotifChannel = lib.mkIf config.programs.claude-code.enable "kitty";
    };
}
