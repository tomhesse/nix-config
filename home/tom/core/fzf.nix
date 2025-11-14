{
  config,
  lib,
  pkgs,
  ...
}:
let
  bat = lib.getExe pkgs.bat;
  eza = lib.getExe pkgs.eza;
  fd = lib.getExe pkgs.fd;
  head = lib.getExe' pkgs.coreutils "head";
in
{
  programs.fzf = {
    enable = true;
    changeDirWidgetCommand = "${fd} --type=d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetOptions = [ "--preview '${eza} --tree --color=always {} ${head} -200'" ];
    defaultCommand = "fd --type=f --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetCommand = config.programs.fzf.defaultCommand;
    fileWidgetOptions = [ "--preview '${bat} -n --color=always --line-range :500 {}'" ];
  };
}
