{
  flake.modules.homeManager.claude =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.claude-code ];

      home.persistence."/persistent" = {
        directories = [ ".claude" ];
        files = [ ".claude.json" ];
      };
    };
}
