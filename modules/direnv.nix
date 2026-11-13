{
  flake.modules.homeManager.direnv =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/direnv"
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
      };

      programs.vscodium.profiles.default = lib.mkIf config.programs.vscodium.enable {
        extensions = [ pkgs.vscode-extensions.mkhl.direnv ];
      };
    };
}
