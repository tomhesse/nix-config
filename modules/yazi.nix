{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;

        plugins = {
          inherit (pkgs.yaziPlugins)
            smart-enter
            smart-paste
            mount
            git
            ;
        };

        initLua = ''
          require("git"):setup()
        '';

        settings.plugin.prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
          }
          {
            id = "git";
            url = "*/";
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
        ];
      };
    };
}
