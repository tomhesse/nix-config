{
  flake.modules.nixos.swaylock = {
    security.pam.services.swaylock = { };
  };

  flake.modules.homeManager.swaylock = {
    programs.swaylock = {
      enable = true;
      settings = {
        ignore-empty-password = true;
        show-failed-attempts = true;
        hide-keyboard-layout = true;
        indicator-caps-lock = true;
        font = "Fira Sans";
        indicator-radius = 100;
        indicator-thickness = 10;
      };
    };
  };
}
