{
  flake.modules.homeManager.bat =
    { config, lib, ... }:
    let
      bat = lib.getExe config.programs.bat.package;
    in
    {
      programs.bat.enable = true;

      programs.fish.shellAbbrs = {
        "--help" = {
          position = "anywhere";
          expansion = "--help | ${bat} -plhelp";
        };
        "-h" = {
          position = "anywhere";
          expansion = "-h | ${bat} -plhelp";
        };
      };
    };
}
