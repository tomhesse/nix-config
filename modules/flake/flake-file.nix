{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.default ];

  flake-file.inputs.flake-file.url = "github:denful/flake-file";
}
