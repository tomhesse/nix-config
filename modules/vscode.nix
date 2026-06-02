{
  flake.modules.homeManager.vscode =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    {
      home.persistence."/persistent" = {
        directories = [
          "${config.xdg.relativeConfigHome}/Code/User"
          ".vscode/cli"
        ];
        files = [ "${config.xdg.relativeConfigHome}/Code/machineid" ];
      };

      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;

        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
            anthropic.claude-code
            jnoortheen.nix-ide
          ];

          userSettings =
            let
              host = osConfig.networking.hostName;
              flake = "(builtins.getFlake (builtins.toString ./. ))";
            in
            {
              "telemetry.telemetryLevel" = "off";
              "update.mode" = "none";
              "chat.disableAIFeatures" = true;

              "editor.fontFamily" = "'FiraCode Nerd Font', monospace";
              "editor.fontSize" = 14;
              "editor.formatOnSave" = true;
              "terminal.integrated.fontFamily" = "'FiraCode Nerd Font'";
              "files.autoSave" = "onFocusChange";
              "files.insertFinalNewline" = true;
              "files.trimFinalNewlines" = true;
              "files.trimTrailingWhitespace" = true;

              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
              "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
              "nix.serverSettings" = {
                "nixd" = {
                  "nixpkgs"."expr" = "import ${flake}.inputs.nixpkgs { }";
                  "options" = {
                    "nixos"."expr" = "${flake}.nixosConfigurations.${host}.options";
                    "home-manager"."expr" =
                      "${flake}.nixosConfigurations.${host}.options.home-manager.users.type.getSubOptions []";
                  };
                };
              };
            };
        };
      };
    };
}
