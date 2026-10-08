{
  flake.modules.homeManager.gh-dash = {
    programs.gh-dash = {
      enable = true;
      settings.repoPaths."tomhesse/nix-config" = "~/projects/nix/nix-config";
    };
  };
}
