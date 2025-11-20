{ config, lib, ... }:
let
  inherit (lib) getName mkOption types;
in
{
  options.hostSpec.allowedUnfree = mkOption {
    type = types.listOf types.str;
    default = [ ];
    description = "A list of unfree packages that can be installed.";
  };

  config = {
    nixpkgs.config = {
      allowUnfreePredicate = pkg: builtins.elem (getName pkg) config.hostSpec.allowedUnfree;
    };
  };
}
