{
  config,
  lib,
  pkgs,
  ...
}:
let
  relativeStateHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.stateHome;
in
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 10;
    extraConfig = ''
      bind R source-file '${config.xdg.configHome}/tmux/tmux.conf'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_user}"
      set -ag status-right "#{E:@catppuccin_status_host}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"
    '';
    focusEvents = true;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-dir '${config.xdg.stateHome}/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      pkgs.tmuxPlugins.vim-tmux-navigator
    ];
    prefix = "C-Space";
    terminal = "tmux-256color";
  };

  catppuccin.tmux.extraConfig = ''
    set -g @catppuccin_window_status_style "rounded"
    set -g @catppuccin_date_time_text " %H:%M"
  '';

  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      "${relativeStateHome}/tmux/resurrect"
    ];
  };
}
