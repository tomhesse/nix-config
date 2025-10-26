{
  globals.mapleader = " "; # Set space as leader key

  keymaps = [
    {
      mode = "i";
      key = "jk";
      action = "<ESC>";
      options.desc = "Exit insert mode with jk";
    }
    {
      key = "<leader>nh";
      action = "<cmd>nohlsearch<CR>";
      options.desc = "Clear search highlights";
    }
    {
      key = "<leader>+";
      action = "<C-a>";
      options.desc = "Increment number";
    }
    {
      key = "<leader>-";
      action = "<C-x>";
      options.desc = "Decrement number";
    }
    {
      key = "<leader>sv";
      action = "<C-w>v";
      options.desc = "Split window vertically";
    }
    {
      key = "<leader>sh";
      action = "<C-w>s";
      options.desc = "Split window horizontally";
    }
    {
      key = "<leader>se";
      action = "<C-w>=";
      options.desc = "Make splits equal size";
    }
    {
      key = "<leader>sx";
      action = "<cmd>close<CR>";
      options.desc = "Close current split";
    }
    {
      key = "<leader>to";
      action = "<cmd>tabnew<CR>";
      options.desc = "Open new tab";
    }
    {
      key = "<leader>tx";
      action = "<cmd>tabclose<CR>";
      options.desc = "Close current tab";
    }
    {
      key = "<leader>tn";
      action = "<cmd>tabn<CR>";
      options.desc = "Go to next tab";
    }
    {
      key = "<leader>tp";
      action = "<cmd>tabp<CR>";
      options.desc = "Go to previous tab";
    }
    {
      key = "<leader>tf";
      action = "<cmd>tabnew %<CR>";
      options.desc = "Open current buffer in new tab";
    }
  ];
}
