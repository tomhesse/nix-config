{ self, ... }:
{
  flake.modules.nixos.auto-upgrade = {
    imports = [ self.modules.nixos.notify-failure ];

    # The flake URI carries no fragment: nixos-rebuild resolves
    # nixosConfigurations.<hostname> on its own, so this stays host-agnostic.
    system.autoUpgrade = {
      enable = true;
      flake = "github:tomhesse/nix-config";
      operation = "switch";

      # --upgrade only updates channels, which are disabled here, so for a
      # flake system it does nothing but log two warnings per run.
      upgrade = false;

      dates = "10:00";
      randomizedDelaySec = "15m";

      # The window is a check after the build, not a wait: finishing before
      # lower skips the reboot just like finishing after upper, so dates sits on
      # the lower edge and the window spans the build-time variance. 10:00-12:00
      # is the gap between restic-sanity (09:00, +1h jitter) and restic-check
      # (noon on the 1st, long).
      allowReboot = true;
      rebootWindow = {
        lower = "10:00";
        upper = "12:00";
      };
    };

    systemd.services.nixos-upgrade.onFailure = [ "notify-failure@%N.service" ];
  };
}
