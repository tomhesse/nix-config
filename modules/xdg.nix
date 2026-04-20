{
  flake.modules.homeManager.xdg =
    { config, lib, ... }:
    let
      inherit (lib) mkOption removePrefix types;
      mkRelative = path: removePrefix "${config.home.homeDirectory}/" path;
      mkOpt =
        description:
        mkOption {
          type = types.str;
          readOnly = true;
          inherit description;
        };
    in
    {
      options.xdg = {
        relativeCacheHome = mkOpt "XDG cache directory relative to $HOME";
        relativeConfigHome = mkOpt "XDG config directory relative to $HOME";
        relativeDataHome = mkOpt "XDG data directory relative to $HOME";
        relativeStateHome = mkOpt "XDG state directory relative to $HOME";
      };

      config = {
        xdg = {
          enable = true;

          relativeCacheHome = mkRelative config.xdg.cacheHome;
          relativeConfigHome = mkRelative config.xdg.configHome;
          relativeDataHome = mkRelative config.xdg.dataHome;
          relativeStateHome = mkRelative config.xdg.stateHome;
        };
      };
    };
}
