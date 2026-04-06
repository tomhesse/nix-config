{ inputs, ... }:
{
  imports = [ inputs.pkgs-by-name-for-flake-parts.flakeModule ];

  flake-file.inputs.pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

  perSystem.pkgsDirectory = ../../packages;
}
