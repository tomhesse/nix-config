{
  flake.modules.nixos.time =
    { lib, ... }:
    {
      time.timeZone = lib.mkDefault "UTC";
    };
}
