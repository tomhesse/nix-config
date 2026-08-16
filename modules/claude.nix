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
        allowed-tools: Bash(git status:*), Bash(git diff:*)
        description: Suggest a commit message
        ---

        ## Context

        - Current git status: !`git status`
        - Current git diff: !`git diff HEAD`
        - Current branch: !`git branch --show-current`

        ## Your task

        Suggest a single concise conventional commit message for the current changes.
        Output only the commit message as a code block. Do not stage or commit anything.
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
        model = "opus";
      };
    };
  };
}
