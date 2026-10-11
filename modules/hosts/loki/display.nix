{
  configurations.nixos.loki.module =
    { pkgs, ... }:
    {
      home-manager.users.thesse.wallpaper = pkgs.fetchurl {
        url = "https://w.wallhaven.cc/full/k8/wallhaven-k899o7.png";
        sha256 = "sha256-36sgTh1D/8KQlLhx/ZfhwFyoXfO59JoOBZnJFPjligM=";
      };

      monitors = {
        eDP-1 = {
          resolution = "2880x1920";
          refreshRate = 120;
          scale = 2;
          primary = true;
        };
      };
    };
}
