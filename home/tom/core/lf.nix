{ lib, pkgs, ... }:
let
  eza = lib.getExe pkgs.eza;
  lf = lib.getExe pkgs.lf;
  sed = lib.getExe pkgs.gnused;
  zoxide = lib.getExe pkgs.zoxide;
in
{
  programs.lf = {
    enable = true;
    commands = {
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
  };
}
