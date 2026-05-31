{
  flake.modules.homeManager.nh =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        flake = "${config.xdg.userDirs.extraConfig.PROJECTS}/nix/nix-config";
      };
    };
}
