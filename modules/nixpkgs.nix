{
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-lib.follows = "nixpkgs";
  };

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
          "osu-lazer-bin"
          "steam"
          "steam-unwrapped"
        ];
    };
}
