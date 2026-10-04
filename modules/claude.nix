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
            wrapProgram $out/bin/claude --prefix PATH : ${
              lib.makeBinPath [
                pkgs.nodejs
                pkgs.uv
              ]
            }
          '';
        })
      ];

      home.persistence."/persistent" = {
        directories = [ ".claude" ];
        files = [ ".claude.json" ];
      };
    };
}
