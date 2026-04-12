{
  flake.modules.homeManager.claude = {
    home.persistence."/persistent" = {
      directories = [ ".claude/projects" ];
      files = [ ".claude/.credentials.json" ];
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
