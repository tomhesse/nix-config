{ inputs, ... }:
let
  overlay = _final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      inherit (prev) config;
    };
  };
in
{
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-lib.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  flake.overlays.unstable = overlay;

  flake.modules.nixos.nixpkgs =
    { lib, ... }:
    {
      nixpkgs = {
        overlays = [ overlay ];

        config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "claude-code"
            "nvidia-kernel-modules"
            "nvidia-settings"
            "nvidia-x11"
            "obsidian"
            "osu-lazer-bin"
            "steam"
            "steam-unwrapped"
            "unrar"
            "vscode"
            "vscode-extension-anthropic-claude-code"
          ];
      };
    };
}
