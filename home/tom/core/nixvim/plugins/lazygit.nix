{
  plugins.lazygit.enable = true;

  keymaps = [
    {
      key = "<leader>lg";
      action = "<cmd>LazyGit<CR>";
      options.desc = "Open lazygit";
    }
  ];
}
