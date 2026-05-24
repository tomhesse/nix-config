{
  flake.modules.nixos.gnome-keyring = {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
  };

  flake.modules.homeManager.gnome-keyring =
    { config, ... }:
    {
      services.gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
      };

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/keyrings"
      ];
    };
}
