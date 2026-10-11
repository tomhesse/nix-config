{ lib, moduleLocation, ... }:
let
  inherit (lib) mapAttrs mkOption types;
  inherit (lib.strings) escapeNixIdentifier;

  addInfo =
    class: name:
    if class == "generic" then
      module: module
    else
      module:
      let
        location = "${toString moduleLocation}#modules.${escapeNixIdentifier class}.${escapeNixIdentifier name}";
      in
      { ... }:
      {
        key = location;
        _class = class;
        _file = location;
        imports = [ module ];
      };
in
{
  options.flake.modules = mkOption {
    type = types.lazyAttrsOf (types.lazyAttrsOf types.deferredModule);
    description = "Groups of modules published by the flake, keyed by class.";
    apply = mapAttrs (class: mapAttrs (addInfo class));
  };
}
