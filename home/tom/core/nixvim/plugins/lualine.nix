{
  plugins.lualine = {
    enable = true;
    settings = {
      sections = {
        lualine_b = [
          "branch"
          "diff"
          {
            __unkeyed = "diagnostics";
            symbols = {
              error = "E";
              warn = "W";
              info = "I";
              hint = "H";
            };
          }
        ];
      };
    };
  };
}
