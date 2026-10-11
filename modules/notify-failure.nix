{ self, ... }:
{
  flake.modules.nixos.notify-failure =
    { config, pkgs, ... }:
    let
      address = config.msmtp.adminAddress;

      notify = pkgs.writeShellScript "notify-failure" ''
        {
          printf 'To: %s\n' ${address}
          printf 'Subject: [%s] %s failed\n\n' ${config.networking.hostName} "$1"
          ${pkgs.systemd}/bin/systemctl status --full --lines=50 -- "$1" || true
        } | /run/current-system/sw/bin/sendmail ${address}
      '';
    in
    {
      imports = [ self.modules.nixos.msmtp ];

      systemd.services."notify-failure@" = {
        description = "Failure notification for %i";

        startLimitBurst = 12;
        startLimitIntervalSec = 2 * 60 * 60;

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${notify} %i";
          Restart = "on-failure";
          RestartMode = "direct";
          RestartSec = "5min";
        };
      };
    };
}
