{
  flake.modules.homeManager.wlsunset = {
    services.wlsunset = {
      enable = true;
      systemdTarget = ''wayland-session@niri\x2dsession.target'';
      latitude = 53.08;
      longitude = 8.80;
      temperature = {
        day = 6500;
        night = 5500;
      };
    };
  };
}
