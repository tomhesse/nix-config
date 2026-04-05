{
  flake.modules.homeManager.fonts =
    { pkgs, ... }:
    {
      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "FiraCode Nerd Font" ];
          sansSerif = [ "Fira Sans" ];
          serif = [ "Fira Sans" ];
        };
      };
      home.packages = [
        pkgs.fira
        pkgs.nerd-fonts.fira-code
      ];
    };
}
