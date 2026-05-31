{
  flake.modules.homeManager.hyprpaper =
    { config, ... }:
    {
      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          wallpaper = {
            monitor = "";
            path = "${config.wallpaper}";
          };
        };
      };
    };
}
