{
  flake.modules.nixos.lts-kernel =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages;
    };
}
