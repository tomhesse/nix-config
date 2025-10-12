{ hostName, lib, ... }:
{
  networking = {
    inherit hostName;
    domain = lib.mkDefault "shrimphouse.xyz";
  };
}
