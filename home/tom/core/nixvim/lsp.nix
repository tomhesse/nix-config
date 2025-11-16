{ lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  lsp = {
    inlayHints.enable = true;
    keymaps = [
      {
        action = mkRaw "require('telescope.builtin').lsp_references";
        key = "gR";
        mode = "n";
        options.desc = "Show LSP references";
      }
      {
        lspBufAction = "declaration";
        key = "gD";
        mode = "n";
        options.desc = "Go to declaration";
      }
      {
        action = mkRaw "require('telescope.builtin').lsp_definitions";
        key = "gd";
        mode = "n";
        options.desc = "Show LSP definitions";
      }
      {
        action = mkRaw "require('telescope.builtin').lsp_implementations";
        key = "gi";
        mode = "n";
        options.desc = "Show LSP implementations";
      }
      {
        action = mkRaw "require('telescope.builtin').lsp_type_definitions";
        key = "gt";
        mode = "n";
        options.desc = "Show LSP type definitions";
      }
      {
        lspBufAction = "code_action";
        key = "<leader>ca";
        mode = [
          "n"
          "v"
        ];
        options.desc = "See available code actions";
      }
      {
        lspBufAction = "rename";
        key = "<leader>rn";
        mode = "n";
        options.desc = "Smart rename";
      }
      {
        action = mkRaw "function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end";
        key = "<leader>D";
        mode = "n";
        options.desc = "Show buffer diagnostics";
      }
      {
        action = mkRaw "vim.diagnostic.open_float";
        key = "<leader>d";
        mode = "n";
        options.desc = "Show line diagnostics";
      }
      {
        action = mkRaw "vim.diagnostic.goto_prev";
        key = "[d";
        mode = "n";
        options.desc = "Go to previous diagnostic";
      }
      {
        action = mkRaw "vim.diagnostic.goto_next";
        key = "]d";
        mode = "n";
        options.desc = "Go to next diagnostic";
      }
      {
        lspBufAction = "hover";
        key = "K";
        mode = "n";
        options.desc = "Show documentation for what is under cursor";
      }
    ];
    servers = {
      nixd.enable = true;
    };
  };
}
