{
  flake.modules.homeManager.utilities =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bluetui
        opentofu
        wl-clipboard
      ];
    };
}
