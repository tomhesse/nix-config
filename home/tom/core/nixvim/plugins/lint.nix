{
  plugins.lint = {
    enable = false;
    autoCmd.event = [
      "BufEnter"
      "BufWritePost"
      "InsertLeave"
    ];
    lintersByFt = {
      nix = [
        "nix"
        "deadnix"
        "statix"
      ];
    };
  };
}
