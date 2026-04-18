{
  flake.modules.homeManager.claude = {
    home.persistence."/persistent" = {
      directories = [ ".claude" ];
      files = [ ".claude.json" ];
    };
    programs.claude-code = {
      enable = true;
      commands.commit = ''
        ---
        allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*)
        description: Create a git commit
        ---

        ## Context

        - Current git status: !`git status`
        - Current git diff: !`git diff HEAD`
        - Current branch: !`git branch --show-current`

        ## Your task

        Stage all changes and create a single git commit with a concise conventional commit message.
        Do not ask for confirmation. Stage and commit in one step.
      '';
      settings = {
        permissions = {
          allow = [
            "Edit"
          ];
          deny = [
            "Read(./**/secrets.yaml)"
          ];
        };
        includeCoAuthoredBy = false;
        theme = "dark";
      };
    };
  };
}
