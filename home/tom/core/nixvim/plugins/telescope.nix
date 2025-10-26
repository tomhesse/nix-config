{
  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>ff" = {
        action = "find_files";
        options = {
          desc = "Fuzzy find files in cwd";
        };
      };
      "<leader>fr" = {
        action = "oldfiles";
        options = {
          desc = "Fuzzy find recent files";
        };
      };
      "<leader>fs" = {
        action = "live_grep";
        options = {
          desc = "Find string in cwd";
        };
      };
      "<leader>fc" = {
        action = "grep_string";
        options = {
          desc = "Find string under cursor in cwd";
        };
      };
    };
  };
}
