{
  flake.modules.homeManager.claude =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.symlinkJoin {
          name = "claude-code-wrapped";
          paths = [ pkgs.unstable.claude-code ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/claude --prefix PATH : ${pkgs.nodejs}/bin
          '';
        })
      ];

      home.persistence."/persistent" = {
        directories = [ ".claude" ];
        files = [ ".claude.json" ];
      };
    };
}
