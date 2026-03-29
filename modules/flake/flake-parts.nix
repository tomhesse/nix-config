{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  flake-file.inputs.flake-parts = {
    url = "github:hercules-ci/flake-parts";
    inputs.nixpkgs-lib.follows = "nixpkgs-lib";
  };
}
