{ lib }:
{
  basePath,
  hostName,
  hostSpec,
}:
let
  inherit (lib) filterAttrs mapAttrsToList optional;

  assertHostName = lib.assertMsg (hostName != null) "importOptionalHomeModules: hostName is required";

  profileDir = name: basePath + "/${name}";

  enabledProfiles = filterAttrs (
    name: value:
    builtins.isAttrs value && (value.enable or false) && builtins.pathExists (profileDir name)
  ) hostSpec;

  hostModule = optional (builtins.pathExists (basePath + "/hosts/${hostName}")) (
    basePath + "/hosts/${hostName}"
  );
in
assert assertHostName;
mapAttrsToList (name: _: profileDir name) enabledProfiles ++ hostModule
