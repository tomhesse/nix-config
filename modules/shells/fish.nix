{
  flake.modules.nixos.fish = {
    programs.fish.enable = true;
  };

  flake.modules.homeManager.fish =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/fish"
      ];

      programs.fish = {
        enable = true;

        shellAbbrs =
          let
            bat = lib.getExe pkgs.bat;
          in
          {
            gpg-reload = "${lib.getExe' pkgs.gnupg "gpg-connect-agent"} \"scd serialno\" \"learn --force\" /bye";
            "--help" = {
              position = "anywhere";
              expansion = "--help | ${bat} -plhelp";
            };
            "-h" = {
              position = "anywhere";
              expansion = "-h | ${bat} -plhelp";
            };
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
