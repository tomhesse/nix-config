{
  flake.modules.homeManager.kitty =
    { pkgs, ... }:
    {
      programs.kitty = {
        enable = true;

        font = {
          name = "FiraCode Nerd Font";
          package = pkgs.nerd-fonts.fira-code;
        };
      };
    };
}
