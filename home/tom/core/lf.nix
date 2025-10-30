{ lib, pkgs, ... }:
let
  eza = lib.getExe pkgs.eza;
  fd = lib.getExe pkgs.fd;
  fzf = lib.getExe pkgs.fzf;
  lf = lib.getExe pkgs.lf;
  printf = lib.getExe' pkgs.coreutils "printf";
  sed = lib.getExe pkgs.gnused;
  zoxide = lib.getExe pkgs.zoxide;
in
{
  programs.lf = {
    enable = true;
    commands = {
      fzf_jump = ''
          ''${{
            res="$(${fd} --strip-cwd-prefix --exclude .git | ${fzf} --reverse --header="Jump to location")"
            if [ -n "$res" ]; then
                if [ -d "$res" ]; then
                    cmd="cd"
                else
                    cmd="select"
                fi
                res="$(${printf} '%s' "$res" | ${sed} 's/\\/\\\\/g;s/"/\\"/g')"
                lf -remote "send $id $cmd \"$res\""
            fi
        }}
      '';
      on-cd = ''
        &{{
          ${zoxide} add "$PWD"
        }}
      '';
      on-select = ''
        &{{
          ${lf} -remote "send $id set statfmt \"$(${eza} -ld --color=always "$f" | ${sed} 's/\\/\\\\/g;s/"/\\"/g')\""
        }}
      '';
      z = ''
        %{{
          result="$(${zoxide} query --exclude "$PWD" "$@" | ${sed} 's/\\/\\\\/g;s/"/\\"/g')"
          ${lf} -remote "send $id cd \"$result\""
        }}
      '';
      zi = ''
        ''${{
          result="$(zoxide query -i | sed 's/\\/\\\\/g;s/"/\\"/g')"
          lf -remote "send $id cd \"$result\""
        }}
      '';
    };
    keybindings = {
      f = "$$EDITOR $(fzf)";
      "<c-f>" = ":fzf_jump";
    };
  };
}
