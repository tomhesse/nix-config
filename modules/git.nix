{
  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "Tom Hesse";
        user.email = "contact@tomhesse.xyz";
        init.defaultBranch = "main";
      };
      signing.signByDefault = true;
    };
  };
}
