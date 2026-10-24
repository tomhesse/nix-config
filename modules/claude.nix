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
    {
      programs.claude-code = {
        enable = true;
        configDir = "${config.xdg.configHome}/claude";
        settings = {
          theme = "auto";
          sandbox.enabled = true;
        };
      };

      programs.vscode.profiles.default = lib.mkIf config.programs.vscode.enable {
        extensions = [ pkgs.vscode-extensions.anthropic.claude-code ];

        userSettings."claudeCode.hideOnboarding" = true;
      };

      home.packages = with pkgs; [
        bubblewrap
        socat
      ];

      home.persistence."/persistent".directories = [ ".config/claude" ];
    };
}
