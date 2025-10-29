{
  config,
  inputs,
  lib,
  ...
}:
let
  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
  relativeStateHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.stateHome;
in
{
  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [
      "${relativeDataHome}/nvim"
      "${relativeStateHome}/nvim"
    ];
  };

  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    imports = lib.mapAttrsToList (name: _: ./. + "/${name}") (
      lib.filterAttrs (
        name: type:
        (type == "directory" || (lib.hasSuffix ".nix" name && name != "default.nix"))
        && !(lib.hasPrefix "." name)
      ) (builtins.readDir ./.)
    );
  };
}
