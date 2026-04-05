{
  flake.modules.homeManager.xdg =
    { config, lib, ... }:
    let
      mkRelative = path: lib.removePrefix "${config.home.homeDirectory}/" path;
      mkOpt =
        description:
        lib.mkOption {
          type = lib.types.str;
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
