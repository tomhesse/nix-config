{
  flake.modules.nixos.xdg-desktop-portal =
    { pkgs, ... }:
    {
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];

      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
}
