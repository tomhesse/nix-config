{
  plugins.nvim-autopairs = {
    enable = true;
    luaConfig.post = ''
      require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    '';
    settings = {
      check_ts = true;
    };
  };
}
