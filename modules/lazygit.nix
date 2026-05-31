{
  flake.modules.homeManager.lazygit =
    { config, ... }:
    {
      home.persistence."/persistent".files = [
        "${config.xdg.relativeStateHome}/lazygit/state.yml"
      ];

      programs.lazygit = {
        enable = true;
        settings = {
          promptToReturnFromSubprocess = false;
          git.autoFetch = false;
          gui.mouseEvents = false;
        };
      };
    };
}
