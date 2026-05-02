{
  flake.modules.homeManager.utilities =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bluetui
        ldns
        opentofu
        wl-clipboard
      ];
    };
}
