{
  programs.git = {
    enable = true;
    userName = "Tom Hesse";
    userEmail = "contact@tomhesse.xyz";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    signing = {
      signByDefault = true;
    };
  };
}
