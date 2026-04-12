{ inputs, ... }:
{
  flake.modules.nixos.theme = {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];

    catppuccin.enable = true;

    console.earlySetup = true;
  };

  flake.modules.homeManager.theme = {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];

    catppuccin = {
      enable = true;
      cursors.enable = true;
      tmux.extraConfig = ''
        set -g @catppuccin_window_status_style "rounded"
        set -g @catppuccin_date_time_text " %H:%M"
      '';
    };
  };
}
