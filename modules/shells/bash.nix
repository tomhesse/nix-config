{
  flake.modules.nixos.bash = {
    programs.bash.completion.enable = true;
  };

  flake.modules.homeManager.bash =
    { config, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeStateHome}/bash"
      ];

      programs.bash = {
        enable = true;
        historyFile = "${config.xdg.stateHome}/bash/history";
        historyControl = [
          "erasedups"
          "ignoredups"
          "ignorespace"
        ];
        initExtra = ''
          PROMPT_COMMAND='printf "\033]0;%s\007" "''${PWD/#$HOME/\~}"'

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
    };
}
