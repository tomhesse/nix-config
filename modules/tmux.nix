{
  flake.modules.homeManager.tmux =
    { config, pkgs, ... }:
    let
      continuum = "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum";
    in
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
          set -g status-right "#(${continuum}/scripts/continuum_save.sh)"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_user}"
          set -ag status-right "#{E:@catppuccin_status_host}"
          set -ag status-right "#{E:@catppuccin_status_date_time}"
        '';
        focusEvents = true;
        historyLimit = 50000;
        keyMode = "vi";
        mouse = true;
        plugins = [
          pkgs.tmuxPlugins.vim-tmux-navigator
          {
            plugin = pkgs.tmuxPlugins.resurrect;
            extraConfig = ''
              set -g @resurrect-dir '${config.xdg.stateHome}/tmux/resurrect'
              set -g @resurrect-capture-pane-contents 'on'
            '';
          }
          {
            plugin = pkgs.tmuxPlugins.continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '10'
            '';
          }
        ];
        prefix = "C-Space";
        terminal = "tmux-256color";
      };
    };
}
