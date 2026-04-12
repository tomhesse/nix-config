{
  flake.modules.homeManager.claude = {
    home.persistence."/persistent" = {
      directories = [ ".claude" ];
      files = [ ".claude.json" ];
    };
    programs.claude-code = {
      enable = true;
      settings = {
        permissions = {
          allow = [
            "Bash(git diff:*)"
            "Edit"
          ];
          deny = [
            "Read(./**/secrets.yaml)"
          ];
        };
        theme = "dark";
      };
    };
  };
}
