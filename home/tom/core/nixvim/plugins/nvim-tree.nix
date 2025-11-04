{
  plugins.nvim-tree = {
    enable = true;
    autoClose = true;
  };

  keymaps = [
    {
      key = "<leader>ee";
      action = "<cmd>NvimTreeToggle<CR>";
      options.desc = "Toggle file explorer";
    }
    {
      key = "<leader>eo";
      action = "<cmd>NvimTreeFocus<CR>";
      options.desc = "Focus file explorer";
    }
    {
      key = "<leader>ef";
      action = "<cmd>NvimTreeFindFile<CR>";
      options.desc = "Find current file in file explorer";
    }
    {
      key = "<leader>ec";
      action = "<cmd>NvimTreeCollapse<CR>";
      options.desc = "Collapses the nvim-tree recursively";
    }
  ];
}
