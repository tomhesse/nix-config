{
  flake.modules.nixos.notify-failure =
    { config, pkgs, ... }:
    let
      address = "admin@shrimphouse.xyz";

      notify = pkgs.writeShellScript "notify-failure" ''
        {
          printf 'To: %s\n' ${address}
          printf 'Subject: [%s] %s failed\n\n' ${config.networking.hostName} "$1"
          ${pkgs.systemd}/bin/systemctl status --full --lines=50 -- "$1" || true
        } | /run/current-system/sw/bin/sendmail ${address}
      '';
    in
    {
      systemd.services."notify-failure@" = {
        description = "Failure notification for %i";

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${notify} %i";
        };
      };
    };
}
