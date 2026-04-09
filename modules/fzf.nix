{
  flake.modules.homeManager.fzf =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) getExe getExe';
      bat = getExe pkgs.bat;
      eza = getExe pkgs.eza;
      fd = getExe pkgs.fd;
      head = getExe' pkgs.coreutils "head";
    in
    {
      programs.fzf = {
        enable = true;
        defaultCommand = "${fd} --type=f --hidden --strip-cwd-prefix --exclude .git";
        fileWidgetCommand = config.programs.fzf.defaultCommand;
        fileWidgetOptions = [ "--preview '${bat} -n --color=always --line-range :500 {}'" ];
        changeDirWidgetCommand = "${fd} --type=d --hidden --strip-cwd-prefix --exclude .git";
        changeDirWidgetOptions = [ "--preview '${eza} --tree --color=always {} | ${head} -200'" ];
      };
    };
}
