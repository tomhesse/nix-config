{ self, ... }:
{
  configurations.nixos.tyr.module =
    { pkgs, ... }:
    {
      imports = [ self.modules.nixos.desk-monitors ];

      home-manager.users.thesse.wallpaper = pkgs.fetchurl {
        url = "https://w.wallhaven.cc/full/ly/wallhaven-lyqjly.png";
        sha256 = "sha256-/X64eC0yvoIq92ib084qpR5T/CDYl+EFMdFd/cjDRSk=";
      };

      monitors.DP-1.primary = true;
    };
}
