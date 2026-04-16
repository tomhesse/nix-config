{
  flake.modules.homeManager.utilities =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        wl-clipboard
      ];
    };
}
