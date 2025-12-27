{
  plugins.nerdy = {
    enable = true;
    enableTelescope = true;
  };

  keymaps = [
    {
      key = "<leader>fn";
      action = "<cmd>Telescope nerdy<CR>";
      options.desc = "Nerd Font picker (Telescope)";
    }
  ];
}
