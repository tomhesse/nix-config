{
  allowedUnfree = [ "vscode" ];

  flake.modules.homeManager.vscode =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.persistence."/persistent" = {
        directories = [
          "${config.xdg.relativeConfigHome}/Code/User"
          ".vscode-shared"
          ".vscode/cli"
        ];
        files = [ "${config.xdg.relativeConfigHome}/Code/machineid" ];
      };

      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;

        profiles.default = {
          extensions = [ pkgs.vscode-extensions.christian-kohler.path-intellisense ];

          userSettings = {
            "workbench.startupEditor" = "none";
            "telemetry.telemetryLevel" = "off";
            "update.mode" = "none";
            "security.workspace.trust.enabled" = false;
            "chat.disableAIFeatures" = true;

            "editor.fontFamily" = "'FiraCode Nerd Font', monospace";
            "editor.fontSize" = 14;
            "editor.formatOnSave" = true;
            "terminal.integrated.fontFamily" = "'FiraCode Nerd Font'";
            "files.autoSave" = "onFocusChange";

            "git.closeDiffOnOperation" = true;
            "typescript.suggest.paths" = false;
            "javascript.suggest.paths" = false;
          };
        };
      };
    };
}
