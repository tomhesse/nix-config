{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) getExe getExe' mkIf;

  gpgConnectAgent = getExe' pkgs.gnupg "gpg-connect-agent";
  bat = getExe pkgs.bat;

  enabled = osConfig.hostSpec.shells.fish.enable or false;
  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  config = mkIf enabled {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
      plugins = [
        {
          name = "autopair";
          inherit (pkgs.fishPlugins.autopair) src;
        }
        {
          name = "git-abbr";
          inherit (pkgs.fishPlugins.git-abbr) src;
        }
        {
          name = "sudope";
          inherit (pkgs.fishPlugins.plugin-sudope) src;
        }
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
      shellAbbrs = {
        gpgkick = ''${gpgConnectAgent} "scd serialno" "learn --force" /bye'';
        lg = "lazygit";
        "--help" = {
          position = "anywhere";
          expansion = "--help | ${bat} -plhelp";
        };
        "-h" = {
          position = "anywhere";
          expansion = "-h | ${bat} -plhelp";
        };
      };
    };

    home.persistence = mkIf impermanenceEnabled {
      "/persist${config.home.homeDirectory}" = {
        directories = [
          "${relativeDataHome}/fish"
        ];
      };
    };
  };
}
