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
            lg = lib.getExe pkgs.lazygit;
            ssh-nohost = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
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
          set -g fish_tmux_default_session_name Main
          if not set -q ZED_TERM; and isatty stdout
            set -g fish_tmux_autostart true
          end
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
            {
              name = "tmux";
              src = pkgs.fetchFromGitHub {
                owner = "budimanjojo";
                repo = "tmux.fish";
                rev = "db0030b7f4f78af4053dc5c032c7512406961ea5";
                sha256 = "sha256-rRibn+FN8VNTSC1HmV05DXEa6+3uOHNx03tprkcjjs8=";
              };
            }
          ];
      };
    };
}
