{ config, lib, ... }:
let
  inherit (lib)
    attrNames
    concatStringsSep
    filterAttrs
    mkEnableOption
    mkOption
    optional
    types
    ;

  usersDir = ./../users;
  usersDirContents = builtins.readDir usersDir;

  availableUsers = builtins.filter (name: usersDirContents.${name} == "directory") (
    attrNames usersDirContents
  );

  declaredUsers = config.hostSpec.users or { };
  enabledUsers = filterAttrs (_: user: user.enable or false) declaredUsers;

  enabledUserNames = attrNames enabledUsers;

  missingModules = builtins.filter (user: !(builtins.elem user availableUsers)) enabledUserNames;

  userModules = map (name: usersDir + "/${name}") availableUsers;
in
{
  imports = userModules;

  options.hostSpec.users = mkOption {
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options.enable = mkEnableOption "Enable user ${name}";
        }
      )
    );
    default = { };
    description = "Per-user enable flags (definitions live in modules/users/<name>/default.nix).";
  };

  config = {
    users.mutableUsers = false;

    warnings = optional (missingModules != [ ]) (
      let
        list = concatStringsSep ", " missingModules;
      in
      "The following users are enabled in hostSpec.users but have no module under modules/users/: ${list}"
    );
  };
}
