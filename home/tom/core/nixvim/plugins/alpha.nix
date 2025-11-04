{
  plugins.alpha = {
    enable = true;
    layout = [
      {
        type = "padding";
        val = 2;
      }

      {
        type = "text";
        val = [
          "                                                     "
          "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ "
          "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ "
          "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ "
          "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ "
          "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ "
          "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ "
          "                                                     "
        ];
        opts = {
          position = "center";
          hl = "Keyword";
        };
      }

      {
        type = "padding";
        val = 2;
      }

      {
        type = "group";
        opts = {
          spacing = 1;
        };
        val = [
          {
            type = "button";
            val = " > New File";
            opts = {
              position = "center";
              keymap = [
                "n"
                "e"
                ":ene <CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              shortcut = "e";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
            on_press.__raw = ''function() vim.cmd("ene") end'';
          }
          {
            type = "button";
            val = " > Toggle file explorer";
            opts = {
              position = "center";
              keymap = [
                "n"
                "<leader>ee"
                ":NvimTreeToggle<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              shortcut = "LDR ee";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
            on_press.__raw = ''function() vim.cmd("NvimTreeToggle") end'';
          }
          {
            type = "button";
            val = "󰱼 > Find File";
            opts = {
              position = "center";
              keymap = [
                "n"
                "<leader>ff"
                ":Telescope find_files<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              shortcut = "LDR ff";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
            on_press.__raw = ''function() vim.cmd("Telescope find_files") end'';
          }
          {
            type = "button";
            val = " > Find Recent";
            opts = {
              position = "center";
              keymap = [
                "n"
                "<leader>fr"
                ":Telescope oldfiles<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              shortcut = "LDR fr";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
            on_press.__raw = ''function() vim.cmd("Telescope oldfiles") end'';
          }
          {
            type = "button";
            val = " > Quit NVIM";
            opts = {
              position = "center";
              keymap = [
                "n"
                "q"
                ":qa<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              shortcut = "q";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
            on_press.__raw = ''function() vim.cmd("qa") end'';
          }
        ];
      }
    ];
  };
}
