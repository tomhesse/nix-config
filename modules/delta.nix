{
  flake.modules.homeManager.delta =
    { config, lib, ... }:
    let
      delta = lib.getExe config.programs.delta.package;
    in
    {
      programs = {
        delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            navigate = true;
            line-numbers = true;
          };
        };

        gh.settings.pager = delta;
        gh-dash.settings.pager.diff = "${delta} --paging always";
        lazygit.settings.git.pagers = [ { pager = "${delta} --paging=never"; } ];
      };
    };
}
