{
  flake.modules.homeManager.claude =
    { lib, pkgs, ... }:
    {
      home.packages = [
        (pkgs.symlinkJoin {
          name = "claude-code-wrapped";
          paths = [ pkgs.unstable.claude-code ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/claude \
              --prefix PATH : ${
                lib.makeBinPath [
                  pkgs.nodejs
                  pkgs.uv
                  pkgs.python3
                ]
              } \
              --set UV_PYTHON_DOWNLOADS never
          '';
        })
      ];

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
