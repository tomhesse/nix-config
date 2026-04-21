{
  flake.modules.nixos.nix = {
    nix = {
      channel.enable = false;
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
      settings = {
        auto-optimise-store = true;
        connect-timeout = 5;
        download-buffer-size = 500 * 1024 * 1024;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        max-free = 1024 * 1024 * 1024;
        min-free = 100 * 1024 * 1024;
        warn-dirty = false;
      };
    };
  };
}
