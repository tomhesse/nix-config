{
  flake.modules.nixos.smartd = {
    services.smartd = {
      enable = true;
      defaults.monitored = "-a -o on -S on -R 5 -R 197 -s (S/../.././05|L/../../3/06)";
      notifications.mail = {
        enable = true;
        recipient = "admin@shrimphouse.xyz";
        sender = "smartd@mail.shrimphouse.xyz";
      };

    };
  };
}
