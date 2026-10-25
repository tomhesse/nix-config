{
  flake.modules.homeManager.vscodium =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.persistence."/persistent" = {
        directories = [
          "${config.xdg.relativeConfigHome}/VSCodium/User"
          "${config.xdg.relativeConfigHome}/VSCodium/Backups"
          ".vscode-oss-shared"
        ];
        files = [ "${config.xdg.relativeConfigHome}/VSCodium/machineid" ];
      };

      programs.vscodium = {
        enable = true;
        mutableExtensionsDir = false;

        profiles.default = {
          extensions = [ pkgs.vscode-extensions.christian-kohler.path-intellisense ];

          userSettings = {
            "workbench.startupEditor" = "none";
            "security.workspace.trust.enabled" = false;

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
