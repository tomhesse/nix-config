{
  flake.modules.homeManager.zed =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.persistence."/persistent".directories = [ "${config.xdg.relativeDataHome}/zed" ];

      programs.zed-editor = {
        enable = true;

        extensions = [
          "catppuccin-icons"
          "nix"
        ];

        mutableUserSettings = false;
        mutableUserKeymaps = false;
        mutableUserTasks = false;
        mutableUserDebug = false;

        userSettings = {
          auto_update = false;
          telemetry = {
            metrics = false;
            diagnostics = false;
          };
          title_bar.show_sign_in = false;
          vim_mode = true;

          ui_font_family = "FiraCode Nerd Font";
          buffer_font_family = "FiraCode Nerd Font";

          diagnostics.inline.enabled = true;

          lsp.nixd.binary.path = lib.getExe pkgs.nixd;
        };
      };
    };
}
