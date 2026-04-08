{
  flake.modules.nixos.fish = {
    programs.fish.enable = true;
  };

  flake.modules.homeManager.fish =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;

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
