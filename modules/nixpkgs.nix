{
  flake.modules.nixos.nixpkgs =
    { lib, ... }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
        ];
    };
}
