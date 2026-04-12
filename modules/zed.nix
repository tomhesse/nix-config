{
  flake.modules.homeManager.zed =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    {
      home.persistence."/persistent".directories = [ "${config.xdg.relativeDataHome}/zed" ];

      programs.zed-editor = {
        enable = true;

        extensions = [
          "catppuccin-icons"
          "comment"
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
          autosave = "on_focus_change";
          vim_mode = false;

          ui_font_family = "FiraCode Nerd Font";
          buffer_font_family = "FiraCode Nerd Font";

          diagnostics.inline.enabled = true;

          languages.Nix.language_servers = [
            "nixd"
            "!nil"
          ];

          lsp.nixd = {
            binary.path = lib.getExe pkgs.nixd;
            settings =
              let
                host = osConfig.networking.hostName;
                flake = "(builtins.getFlake (builtins.toString ./.))";
              in
              {
                formatting.command = [ (lib.getExe pkgs.nixfmt) ];
                nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
                options = {
                  nixos.expr = "${flake}.nixosConfigurations.${host}.options";
                  home-manager.expr = "${flake}.nixosConfigurations.${host}.options.home-manager.users.type.getSubOptions []";
                };
              };
          };
        };
      };
    };
}
