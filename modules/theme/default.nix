{ inputs, ... }:
{
  flake.modules.nixos.theme = {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];

    catppuccin.enable = true;

    console.earlySetup = true;
  };

  flake.modules.homeManager.theme = {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];

    catppuccin.enable = true;
    catppuccin.cursors.enable = true;
  };
}
