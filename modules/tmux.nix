{
  flake.modules.homeManager.tmux =
    { config, pkgs, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeStateHome}/tmux/resurrect"
      ];

      programs.tmux = {
        enable = true;
        baseIndex = 1;
        clock24 = true;
        escapeTime = 10;
        extraConfig = ''
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
        ];
        prefix = "C-Space";
        terminal = "tmux-256color";
      };
    };
}
