{
  programs.git = {
    enable = true;
    settings = {
      init = {
        defaultBranch = "main";
      };
      user = {
        email = "contact@tomhesse.xyz";
        name = "Tom Hesse";
      };
    };
    signing = {
      signByDefault = true;
    };
  };
}
