{
  flake.modules.nixos.sddm = {
    services.displayManager.sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };

    environment.persistence."/persistent".files = [
      "/var/lib/sddm/state.conf"
    ];
  };
}
