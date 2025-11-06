{
  plugins.cmp = {
    enable = true;
    settings = {
      mapping = {
        "<C-k>" = "cmp.mapping.scroll_docs(-4)";
        "<C-j>" = "cmp.mapping.scroll_docs(4)";
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-e>" = "cmp.mapping.abort()";
        "<CR>" = ''
          cmp.mapping(function(fallback)
            local luasnip = require('luasnip')
            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({
                  select = true,
                })
              end
            else
              fallback()
            end
          end)
        '';
        "<S-Tab>" = ''
          cmp.mapping(function(fallback) -- Select previous cmp item or jump to previous parameter
            local luasnip = require('luasnip')
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" })
        '';
        "<Tab>" = ''
          cmp.mapping(function(fallback) -- Select next cmp item or jump to next parameter
            local luasnip = require('luasnip')
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" })
        '';
      };
      sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
        { name = "luasnip"; }
      ];
    };
  };
}
