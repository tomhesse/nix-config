{ inputs, ... }:
{
  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix/release-26.05";
  };

  flake.modules.nixos.catppuccin = {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];

    catppuccin.enable = true;

    console.earlySetup = true;
  };

  flake.modules.homeManager.catppuccin = {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];

    catppuccin = {
      enable = true;
      cursors.enable = true;
      gemini-cli.enable = false; # TODO: remove after update to 26.11 (https://github.com/catppuccin/nix/issues/974)
      tmux.extraConfig = ''
        set -g @catppuccin_window_status_style "rounded"
        set -g @catppuccin_date_time_text " %H:%M"
      '';
    };
  };
}
