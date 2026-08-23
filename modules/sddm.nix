{
  flake.modules.nixos.sddm =
    { config, ... }:
    let
      inherit (config.catppuccin.cursors) accent flavor;
    in
    {
      services.displayManager.sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = "kwin";
        };

        settings.Theme = {
          CursorTheme = "catppuccin-${flavor}-${accent}-cursors";
          CursorSize = 32;
        };
      };

      environment.persistence."/persistent".files = [
        "/var/lib/sddm/state.conf"
      ];
    };
}
