{
  flake.modules.homeManager.gtk =
    { config, ... }:
    {
      gtk = {
        enable = true;
        gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      };

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "purple";
        icon-theme = config.gtk.iconTheme.name;
      };
    };
}
