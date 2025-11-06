{ hostName, lib, ... }:
{
  config.home.stateVersion = "25.05";

  options = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = hostName;
      readOnly = true;
      description = "Hostname passed from flake.";
    };
  };
}
