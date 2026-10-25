{
  flake.modules.homeManager.editorconfig =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.vscodium.profiles.default = lib.mkIf config.programs.vscodium.enable {
        extensions = [ pkgs.vscode-extensions.editorconfig.editorconfig ];
      };
    };
}
