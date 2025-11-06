{ hmConfig, ... }:
{
  plugins.lsp = {
    enable = true;
    inlayHints = true;
    keymaps.extra = [
      {
        action = {
          __raw = "require('telescope.builtin').lsp_references";
        };
        key = "gR";
        mode = "n";
        options.desc = "Show LSP references";
      }
      {
        action = {
          __raw = "vim.lsp.buf.declaration";
        };
        key = "gD";
        mode = "n";
        options.desc = "Go to declaration";
      }
      {
        action = {
          __raw = "require('telescope.builtin').lsp_definitions";
        };
        key = "gd";
        mode = "n";
        options.desc = "Show LSP definitions";
      }
      {
        action = {
          __raw = "require('telescope.builtin').lsp_implementations";
        };
        key = "gi";
        mode = "n";
        options.desc = "Show LSP implementations";
      }
      {
        action = {
          __raw = "require('telescope.builtin').lsp_type_definitions";
        };
        key = "gt";
        mode = "n";
        options.desc = "Show LSP type definitions";
      }
      {
        action = {
          __raw = "vim.lsp.buf.code_action";
        };
        key = "<leader>ca";
        mode = [
          "n"
          "v"
        ];
        options.desc = "See available code actions";
      }
      {
        action = {
          __raw = "vim.lsp.buf.rename";
        };
        key = "<leader>rn";
        mode = "n";
        options.desc = "Smart rename";
      }
      {
        action = {
          __raw = "function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end";
        };
        key = "<leader>D";
        mode = "n";
        options.desc = "Show buffer diagnostics";
      }
      {
        action = {
          __raw = "vim.diagnostic.open_float";
        };
        key = "<leader>d";
        mode = "n";
        options.desc = "Show line diagnostics";
      }
      {
        action = {
          __raw = "vim.diagnostic.goto_prev";
        };
        key = "[d";
        mode = "n";
        options.desc = "Go to previous diagnostic";
      }
      {
        action = {
          __raw = "vim.diagnostic.goto_next";
        };
        key = "]d";
        mode = "n";
        options.desc = "Go to next diagnostic";
      }
      {
        action = {
          __raw = "vim.lsp.buf.hover";
        };
        key = "K";
        mode = "n";
        options.desc = "Show documentation for what is under cursor";
      }
    ];
    servers = {
      nixd = {
        enable = true;
        settings =
          let
            flake = "(builtins.getFlake (builtins.toString ./.))";
            inherit (hmConfig) hostName;
          in
          {
            options = {
              nixos.expr = "${flake}.nixosConfigurations.${hostName}.options";
              home-manager.expr = "${flake}.nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []";
              nixvim.expr = "(${flake}.inputs.nixvim.lib.evalNixvim { system = builtins.currentSystem; }).options";
              flake-parts.expr = "${flake}.debug.options // ${flake}.currentSystem.options";
            };
          };
      };
    };
  };
}
