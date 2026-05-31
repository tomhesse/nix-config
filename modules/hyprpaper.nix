{
  flake.modules.homeManager.hyprpaper =
    { config, ... }:
    {
      services.hyprpaper = {
        enable = true;
        settings = {
          wallpaper = {
            monitor = "";
            path = "${config.wallpaper}";
          };
        };
      };
    };
}
