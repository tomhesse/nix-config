{
  flake.modules.nixos.fish = {
    programs.fish.enable = true;
  };

  flake.modules.homeManager.fish =
    { lib, pkgs, ... }:
    {
      programs.fish = {
        enable = true;

        shellAbbrs = {
          gpg-reload = "${lib.getExe' pkgs.gnupg "gpg-connect-agent"} \"scd serialno\" \"learn --force\" /bye";
        };

        interactiveShellInit = ''
          set -g fish_greeting
        '';

        plugins =
          let
            plugin = name: {
              inherit name;
              inherit (pkgs.fishPlugins.${name}) src;
            };
          in
          [
            (plugin "autopair")
            (plugin "git-abbr")
            (plugin "plugin-sudope")
          ];
      };
    };
}
