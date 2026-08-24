{
  flake.modules.homeManager.hyprsunset = {
    services.hyprsunset = {
      enable = true;
      systemdTarget = "wayland-session@hyprland.desktop.target";
      settings = {
        profile = [
          {
            time = "07:30";
            identity = true;
          }
          {
            time = "21:00";
            temperature = 5500;
          }
        ];
      };
    };
  };
}
