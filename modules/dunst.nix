{
  flake.modules.homeManager.dunst = {
    services.dunst = {
      enable = true;

      settings.global = {
        font = "Fira Sans 12";
        corner_radius = 8;
        origin = "top-center";
        offset = "0x50";
      };
    };
  };
}
