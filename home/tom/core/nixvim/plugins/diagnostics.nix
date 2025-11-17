{ pkgs, ... }:
{
  extraPackages = builtins.attrValues {
    inherit (pkgs)
      # Formatting
      nixfmt-rfc-style
      prettierd
      # Linting
      deadnix
      markdownlint-cli
      nix
      statix
      ;
  };

  plugins = {
    conform-nvim = {
      enable = true;
      luaConfig.pre = ''
        local slow_format_filetypes = {}
      '';
      settings = {
        formatters_by_ft = {
          markdown = [
            "prettierd"
          ];
          nix = [
            "nixfmt"
          ];
          "_" = [
            "trim_whitespace"
            "trim_newlines"
          ];
        };
        format_on_save = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end

            if slow_format_filetypes[vim.bo[bufnr].filetype] then
              return
            end

            local function on_format(err)
              if err and err:match("timeout$") then
                slow_format_filetypes[vim.bo[bufnr].filetype] = true
              end
            end

            return { timeout_ms = 200, lsp_fallback = true }, on_format
          end
        '';
        format_after_save = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end

            if not slow_format_filetypes[vim.bo[bufnr].filetype] then
              return
            end

            return { lsp_fallback = true }
          end
        '';
      };
    };
    lint = {
      enable = true;
      autoCmd.event = [
        "BufEnter"
        "BufWritePost"
        "InsertLeave"
      ];
      lintersByFt = {
        markdown = [
          "markdownlint"
        ];
        nix = [
          "nix"
          "deadnix"
          "statix"
        ];
      };
    };
    trouble = {
      enable = true;
      settings = {
        auto_close = true;
        auto_refresh = true;
        focus = true;
      };
    };
    todo-comments.enable = true;
  };

  keymaps = [
    {
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options.desc = "Buffer Diagnostics (Trouble)";
    }
    {
      key = "<leader>cs";
      action = "<cmd>Trouble symbols toggle focus=false<CR>";
      options.desc = "Symbols (Trouble)";
    }
    {
      key = "<leader>cl";
      action = "<cmd>Trouble lsp toggle focus=false win.position=right<CR>";
      options.desc = "LSP Definitions / references / ... (Trouble)";
    }
    {
      key = "<leader>xL";
      action = "<cmd>Trouble loclist toggle<CR>";
      options.desc = "Location List (Trouble)";
    }
    {
      key = "<leader>xQ";
      action = "<cmd>Trouble qflist toggle<CR>";
      options.desc = "Quickfix List (Trouble)";
    }
    {
      key = "<leader>xt";
      action = "<cmd>Trouble todo toggle<CR>";
      options.desc = "Todo comments (Trouble)";
    }
    {
      key = "<leader>ft";
      action = "<cmd>TodoTelescope<CR>";
      options.desc = "Todo comments (Telescope)";
    }
  ];
}
