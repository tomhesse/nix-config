{
  flake.modules.nixos.fish = {
    programs.fish.enable = true;
  };

  flake.modules.homeManager.fish =
    { config, pkgs, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/fish"
      ];

      programs.fish = {
        enable = true;

        shellAbbrs.ssh-nohost = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";

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
