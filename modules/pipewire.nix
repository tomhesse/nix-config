{
  flake.modules.nixos.pipewire = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  flake.modules.homeManager.pipewire =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.wiremix ];

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeStateHome}/wireplumber"
      ];
    };
}
