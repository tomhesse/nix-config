{ lib, osConfig, ... }:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.shells.fish.enable or false;
in
{
  config = mkIf enabled {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
      shellAbbrs = {
        gpgkick = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
      };
    };
  };
}
