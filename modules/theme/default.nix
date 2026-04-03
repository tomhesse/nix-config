{ inputs, ... }:
{
  flake.modules.nixos.theme = {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];

    catppuccin.enable = true;
  };
}
