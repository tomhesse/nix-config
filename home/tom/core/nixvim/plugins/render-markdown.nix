{
  plugins.render-markdown.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "<leader>mt";
      action = "<cmd>RenderMarkdown toggle<CR>";
      options.desc = "Toggle markdown rendering";
    }
  ];
}
