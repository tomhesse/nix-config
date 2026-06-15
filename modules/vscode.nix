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
          extensions =
            (with pkgs.vscode-extensions; [
              anthropic.claude-code
              christian-kohler.path-intellisense
              editorconfig.editorconfig
              jnoortheen.nix-ide
            ])
            ++ [
              (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
                mktplcRef = {
                  publisher = "opentofu";
                  name = "vscode-opentofu";
                  version = "0.6.2";
                  hash = "sha256-rgp++YQ8gUBjzeZk3H0XIcDu2Cp7NGuoutI8IGo5cmg=";
                };
              })
            ];

          userSettings =
            let
              host = osConfig.networking.hostName;
              flake = "(builtins.getFlake (builtins.toString ./. ))";
            in
            {
              "telemetry.telemetryLevel" = "off";
              "update.mode" = "none";
              "security.workspace.trust.enabled" = false;
              "chat.disableAIFeatures" = true;
              "claudeCode.preferredLocation" = "panel";

              "editor.fontFamily" = "'FiraCode Nerd Font', monospace";
              "editor.fontSize" = 14;
              "editor.formatOnSave" = true;
              "terminal.integrated.fontFamily" = "'FiraCode Nerd Font'";
              "files.autoSave" = "onFocusChange";

              "git.autofetch" = true;
              "git.closeDiffOnOperation" = true;
              "typescript.suggest.paths" = false;
              "javascript.suggest.paths" = false;

              "opentofu.languageServer.path" = "${pkgs.tofu-ls}/bin/tofu-ls";
              "opentofu.languageServer.tofu.path" = "${pkgs.opentofu}/bin/tofu";

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
