{
  flake.modules.homeManager.tmux =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      continuum = "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum";

      # swap-window errors on an empty slot and move-window on an occupied one, so
      # trying them in order places the window either way, and -d keeps focus on the
      # window that moved. Alt is the modifier because kitty sends a bare digit for
      # ctrl+<n>, which tmux matches as its own select-window binding.
      moveWindowBinds = lib.concatMapStringsSep "\n" (
        slot:
        "bind -N \"Move window to slot ${slot}\" M-${slot} run-shell 'tmux swap-window -d -t :${slot} 2>/dev/null || tmux move-window -t :${slot}'"
      ) (map toString (lib.range 1 9));
    in
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeStateHome}/tmux/resurrect"
      ];

      programs = {
        bash = {
          initExtra = ''
            TMUX_DEFAULT_SESSION_NAME="Main"
            TMUX_AUTOSTART=true
            TMUX_AUTOSTART_ONCE=true
            TMUX_AUTOCONNECT=true
            TMUX_AUTOQUIT=false

            function tmux {
              if [[ $# -eq 0 ]]; then
                if [[ "$TMUX_AUTOCONNECT" == true ]]; then
                  command tmux new-session -A -s "$TMUX_DEFAULT_SESSION_NAME"
                else
                  command tmux new-session -s "$TMUX_DEFAULT_SESSION_NAME"
                fi
              else
                command tmux "$@"
              fi
            }

            function tds {
              local dir=''${PWD##*/}
              local md5
              if command -v md5sum &>/dev/null; then
                md5=$(printf '%s' "$PWD" | md5sum | cut -d ' ' -f 1)
              elif command -v md5 &>/dev/null; then
                md5=$(printf '%s' "$PWD" | md5)
              else
                printf 'tds: md5sum or md5 not found\n' >&2
                return 1
              fi
              command tmux new-session -As "''${dir}-''${md5:0:6}"
            }

            if [[ "$TMUX_AUTOSTART" == true ]] && [[ -z "$TMUX" ]] && [[ -z "$SSH_CONNECTION" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ -t 1 ]]; then
              if [[ "$TMUX_AUTOSTART_ONCE" != true ]] || [[ -z "$TMUX_AUTOSTARTED" ]]; then
                export TMUX_AUTOSTARTED=true
                if [[ "$TMUX_AUTOCONNECT" == true ]]; then
                  command tmux new-session -A -s "$TMUX_DEFAULT_SESSION_NAME"
                else
                  command tmux new-session -s "$TMUX_DEFAULT_SESSION_NAME"
                fi
                [[ "$TMUX_AUTOQUIT" == true ]] && exit
              fi
            fi
          '';

          shellAliases = {
            ta = "tmux attach -t";
            tad = "tmux attach -d -t";
            tkss = "tmux kill-session -t";
            tksv = "tmux kill-server";
            tl = "tmux list-sessions";
            to = "tmux new-session -A -s";
            ts = "tmux new-session -s";
          };
        };

        fish = {
          interactiveShellInit = ''
            set -g fish_tmux_default_session_name Main
            set -g fish_tmux_autoquit false
            if not set -q ZED_TERM; and not set -q SSH_CONNECTION; and isatty stdout
              set -g fish_tmux_autostart true
            end
          '';

          plugins = [
            {
              name = "tmux";
              src = pkgs.fetchFromGitHub {
                owner = "budimanjojo";
                repo = "tmux.fish";
                rev = "db0030b7f4f78af4053dc5c032c7512406961ea5";
                sha256 = "sha256-rRibn+FN8VNTSC1HmV05DXEa6+3uOHNx03tprkcjjs8=";
              };
            }
          ];
        };

        tmux = {
          enable = true;
          baseIndex = 1;
          clock24 = true;
          escapeTime = 10;
          extraConfig = ''
            set -g allow-passthrough on
            set -s extended-keys always
            set -as terminal-features 'xterm*:extkeys'

            bind c new-window -c "~"
            bind C new-window -c "#{pane_current_path}"
            bind | split-window -h -c "#{pane_current_path}"
            unbind '"'
            bind - split-window -v -c "#{pane_current_path}"
            set -g renumber-windows on

            ${moveWindowBinds}
            bind -r -N "Nudge window left" M-p swap-window -d -t :-1
            bind -r -N "Nudge window right" M-n swap-window -d -t :+1

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
    };
}
