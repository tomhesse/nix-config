{
  plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        mode = "tabs";
        diagnostics = "nvim_lsp";
        diagnostics_indicator = ''
          function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and "E " or "W "
            return " " .. icon .. count
          end
        '';
      };
    };
  };
}
