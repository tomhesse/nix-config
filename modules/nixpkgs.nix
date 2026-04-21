{
  flake.modules.nixos.nixpkgs =
    { lib, ... }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "claude-code"
          "nvidia-settings"
          "nvidia-x11"
          "obsidian"
          "steam"
          "steam-unwrapped"
        ];
    };
}
