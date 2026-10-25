{
  flake.modules.homeManager.editorconfig =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.vscode.profiles.default = lib.mkIf config.programs.vscode.enable {
        extensions = [ pkgs.vscode-extensions.editorconfig.editorconfig ];
      };
    };
}
