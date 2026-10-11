{ self, ... }:
{
  flake.modules.nixos.smartd =
    { config, ... }:
    {
      imports = [ self.modules.nixos.msmtp ];

      services.smartd = {
        enable = true;
        defaults.monitored = "-a -o on -S on -R 5 -R 197 -s (S/../.././05|L/../../3/06)";
        notifications.mail = {
          enable = true;
          recipient = config.msmtp.adminAddress;
          sender = "smartd@${config.msmtp.senderDomain}";
        };
      };
    };
}
