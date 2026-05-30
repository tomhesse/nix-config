{ lib, ... }:
{
  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings = {
        user.name = lib.mkDefault "Tom Hesse";
        user.email = lib.mkDefault "contact@tomhesse.xyz";
        init.defaultBranch = "main";
      };
      signing.signByDefault = lib.mkDefault true;
    };
  };
}
