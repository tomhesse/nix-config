{
  config,
  inputs,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig.hostSpec) hostName;

  importAll = import ../../../../lib/importAll.nix { inherit lib; };

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
  relativeStateHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.stateHome;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    globals.hostName = hostName;
    imports = importAll ./.;
  };

  home.persistence = mkIf impermanenceEnabled {
    "/persist${config.home.homeDirectory}" = {
      directories = [
        "${relativeDataHome}/nvim"
        "${relativeStateHome}/nvim"
      ];
    };
  };
}
