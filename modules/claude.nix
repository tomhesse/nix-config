{
  flake.modules.homeManager.claude =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      path = lib.makeBinPath [
        pkgs.nodejs
        pkgs.uv
        pkgs.python3
      ];
    in
    {
      home.packages = [
        (pkgs.symlinkJoin {
          name = "claude-code-wrapped";
          paths = [ pkgs.unstable.claude-code ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/claude \
              --prefix PATH : ${path} \
              --set UV_PYTHON_DOWNLOADS never
          '';
        })
      ];

      programs.vscode.profiles.default = lib.mkIf config.programs.vscode.enable {
        extensions = [ pkgs.unstable.vscode-extensions.anthropic.claude-code ];
        userSettings = {
          "claudeCode.preferredLocation" = "panel";
          "claudeCode.hideOnboarding" = true;
          # The extension runs its bundled binary through this, passing it as $1.
          "claudeCode.claudeProcessWrapper" = "${pkgs.writeShellScript "claude-vscode" ''
            export PATH=${path}:$PATH
            export UV_PYTHON_DOWNLOADS=never
            exec "$@"
          ''}";
        };
      };

      home.persistence."/persistent" = {
        directories = [ ".claude" ];
        files = [ ".claude.json" ];
      };

      sops.secrets = {
        "services/unifi-mcp/password" = { };
        "services/unifi-mcp/api-key" = { };
      };
    };
}
