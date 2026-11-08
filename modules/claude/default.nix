{
  allowedUnfree = [
    "claude-code"
    "vscode-extension-anthropic-claude-code"
  ];

  flake.modules.homeManager.claude =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      vaultPath = "${config.xdg.userDirs.documents}/obsidian/Prime Vault";

      statusline = pkgs.writeShellApplication {
        name = "claude-statusline";
        runtimeInputs = with pkgs; [
          git
          jq
        ];
        text = builtins.readFile ./statusline.sh;
      };
    in
    {
      programs.claude-code = {
        enable = true;
        configDir = "${config.xdg.configHome}/claude";

        skills.obsidian = pkgs.replaceVars ./skills/obsidian.md { inherit vaultPath; };

        settings = {
          theme = "auto";
          sandbox = {
            enabled = true;
            filesystem.allowWrite = [
              "~/.cache/pre-commit"
              vaultPath
            ];
          };
          includeCoAuthoredBy = false;

          statusLine = {
            type = "command";
            command = lib.getExe statusline;
          };
        };
      };

      programs.vscodium.profiles.default = lib.mkIf config.programs.vscodium.enable {
        extensions = [ pkgs.vscode-extensions.anthropic.claude-code ];

        userSettings = {
          "claudeCode.hideOnboarding" = true;
          "claudeCode.preferredLocation" = "panel";
        };
      };

      home.packages = with pkgs; [
        bubblewrap
        socat
      ];

      home.persistence."/persistent".directories = [ ".config/claude" ];
    };
}
