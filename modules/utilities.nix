{
  flake.modules.homeManager.utilities =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bluetui
        ldns
        mcp-nixos
        opentofu
        wl-clipboard
      ];
    };
}
