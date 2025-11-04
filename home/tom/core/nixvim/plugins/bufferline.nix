{
  plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        mode = "tabs";
        diagnostics = "nvim_lsp";
        diagnostics_indicator = ''
          function(count, level, diagnostics_dict, context)
            local s = ""
            for e, n in pairs(diagnostics_dict) do
              local sym = e == "error" and " "
                or (e == "warning" and " " or "" )
              if(sym ~= "") then
                s = s .. n .. sym
              end
            end
            return s
          end
        '';
      };
    };
  };
}
