{
  config,
  inputs,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib)
    filterAttrs
    hasPrefix
    hasSuffix
    mapAttrsToList
    mkIf
    ;

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
    imports = mapAttrsToList (name: _: ./. + "/${name}") (
      filterAttrs (
        name: type:
        (type == "directory" || (hasSuffix ".nix" name && name != "default.nix")) && !(hasPrefix "." name)
      ) (builtins.readDir ./.)
    );
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
