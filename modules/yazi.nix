{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;

        extraPackages = with pkgs; [ trash-cli ];

        plugins = {
          inherit (pkgs.yaziPlugins)
            smart-enter
            smart-paste
            mount
            recycle-bin
            git
            ;
        };

        initLua = ''
          require("git"):setup()
          require("recycle-bin"):setup()
        '';

        settings.plugin.prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];

        keymap.mgr.prepend_keymap = [
          {
            on = "l";
            run = "plugin smart-enter";
            desc = "Enter directory or open file";
          }
          {
            on = "p";
            run = "plugin smart-paste";
            desc = "Paste into hovered directory or CWD";
          }
          {
            on = "M";
            run = "plugin mount";
            desc = "Mount manager";
          }
          {
            on = [
              "R"
              "b"
            ];
            run = "plugin recycle-bin";
            desc = "Open Recycle Bin menu";
          }
        ];
      };
    };
}
