{
  flake.modules.nixos.steam = {
    hardware.xpadneo.enable = true;

    programs.gamescope.enable = true;

    programs.steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };

  flake.modules.homeManager.steam =
    { config, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/Steam"
      ];
    };
}
