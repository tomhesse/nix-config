{
  flake.modules.homeManager.mpv = {
    programs.mpv = {
      enable = true;
      config = {
        profile = "high-quality";
        video-sync = "display-resample";
        interpolation = true;
      };
    };
  };
}
