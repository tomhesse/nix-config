{ inputs, self, ... }:
{
  flake.modules.homeManager.vscodium =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.homeManager.gnome-keyring ];

      home.persistence."/persistent" = {
        directories = [
          "${config.xdg.relativeConfigHome}/VSCodium/User"
          "${config.xdg.relativeConfigHome}/VSCodium/Backups"
          ".vscode-oss-shared"
        ];
        files = [ "${config.xdg.relativeConfigHome}/VSCodium/machineid" ];
      };

      # HACK: build the vscode port with pnpm_10_latest until nixpkgs bumps pnpm_10.
      # catppuccin's vscode port builds with pnpm_10, which nixpkgs now marks
      # insecure at 10.34.0 (CVE-2026-55487 and friends); pnpm_10_latest is the
      # patched 10.34.5.
      catppuccin.sources.vscode = (import inputs.catppuccin { inherit pkgs; }).packages.vscode.override {
        pnpm_10 = pkgs.pnpm_10_latest;
      };

      programs.vscodium = {
        enable = true;
        mutableExtensionsDir = false;

        # Electron picks a password store from XDG_CURRENT_DESKTOP, and niri is not
        # a name it knows, so it falls back to plaintext storage and VSCodium warns
        # that no OS keyring was found. gnome-keyring does own org.freedesktop.secrets
        # here, so name it explicitly instead.
        argvSettings = {
          password-store = "gnome-libsecret";
          enable-crash-reporter = false;
        };

        profiles.default = {
          extensions = [
            pkgs.vscode-extensions.christian-kohler.path-intellisense
            pkgs.vscode-extensions.gruntfuggly.todo-tree
          ];

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
            "git.confirmSync" = false;
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
