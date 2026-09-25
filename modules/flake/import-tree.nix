{
  flake-file = {
    inputs.import-tree.url = "github:denful/import-tree";

    outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
    '';
  };
}
