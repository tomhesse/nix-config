{ inputs, ... }:
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

      # catppuccin's vscode port builds with pnpm_10, which nixpkgs now marks
      # insecure at 10.34.0 (CVE-2026-55487 and friends); pnpm_10_latest is the
      # patched 10.34.5. Drop this once nixpkgs bumps pnpm_10 itself.
      catppuccin.sources.vscode = (import inputs.catppuccin { inherit pkgs; }).packages.vscode.override {
        pnpm_10 = pkgs.pnpm_10_latest;
      };

      programs.vscodium = {
        enable = true;
        mutableExtensionsDir = false;

        profiles.default = {
          extensions = [ pkgs.vscode-extensions.christian-kohler.path-intellisense ];

          userSettings = {
            "workbench.startupEditor" = "none";
            "security.workspace.trust.enabled" = false;
            "json.schemaDownload.trustedDomains" = {
              "https://docs.renovatebot.com/" = true;
            };

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

      programs.niri.settings.window-rules = [
        {
          matches = [ { app-id = "^codium$"; } ];
          open-maximized = true;
        }
      ];
    };
}
