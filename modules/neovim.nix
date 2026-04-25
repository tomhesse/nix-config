{
  flake.modules.homeManager.neovim =
    { config, pkgs, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/nvim"
        "${config.xdg.relativeStateHome}/nvim"
      ];

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        plugins = with pkgs.vimPlugins; [
          nvim-web-devicons
          vim-tmux-navigator
          {
            plugin = lualine-nvim;
            type = "lua";
            config = ''require("lualine").setup()'';
          }
          {
            plugin = comment-nvim;
            type = "lua";
            config = ''require("Comment").setup()'';
          }
        ];
        extraLuaConfig = ''
          vim.opt.mouse = ""
          vim.opt.autoindent = true
          vim.opt.expandtab = true
          vim.opt.smartindent = true
          vim.opt.tabstop = 4
          vim.opt.softtabstop = 4
          vim.opt.shiftwidth = 4
          vim.opt.ignorecase = true
          vim.opt.smartcase = true
          vim.opt.cursorline = true
          vim.opt.scrolloff = 5
          vim.opt.colorcolumn = "120"
          vim.opt.showmode = false
          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.wrap = false
          vim.opt.signcolumn = "yes"
          vim.opt.splitright = true
          vim.opt.splitbelow = true
          vim.opt.undofile = true
          vim.opt.termguicolors = true

          vim.g.mapleader = " "

          vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
          vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
          vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })
          vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
          vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
          vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
          vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })
          vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
          vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
          vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
          vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
          vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
        '';
      };
    };
}
