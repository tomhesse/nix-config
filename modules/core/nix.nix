{
  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      persistent = true;
    };
    settings = {
      connect-timeout = 5;
      min-free = "${toString (100 * 1024 * 1024)}";
      max-free = "${toString (1024 * 1024 * 1024)}";
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      auto-optimise-store = true;
    };
  };
}
