{
  flake.modules.homeManager.nh =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        flake = "${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}/nix/nix-config";
      };
    };
}
