{
  flake.modules.nixos.smartd = {
    services.smartd = {
      enable = true;
      defaults.monitored = "-a -s (S/../.././02|L/../../7/04)";
      notifications.mail = {
        enable = true;
        recipient = "admin@shrimphouse.xyz";
        sender = "smartd@mail.shrimphouse.xyz";
      };

    };
  };
}
