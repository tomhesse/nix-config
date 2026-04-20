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
          git.autoFetch = false;
          gui.mouseEvents = false;
        };
      };
    };
}
