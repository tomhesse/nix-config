{
  flake.modules.homeManager.gh =
    { config, pkgs, ... }:
    let
      token = config.sops.secrets."services/github/token".path;
    in
    {
      programs.gh = {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "gh-wrapped";
          paths = [ pkgs.gh ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/gh \
              --run '[ -r ${token} ] && export GH_TOKEN="$(< ${token})"'
          '';
        };
        settings.git_protocol = "ssh";
        gitCredentialHelper.enable = false;
      };

      sops.secrets."services/github/token" = { };
    };
}
