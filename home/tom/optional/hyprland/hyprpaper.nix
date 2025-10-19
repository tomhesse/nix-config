let
  wallpaper = builtins.fetchurl {
    url = "https://w.wallhaven.cc/full/x6/wallhaven-x6x3gz.png";
    sha256 = "1cwr17505kfllz39bp1gzm0jkh1mamfjil25ablqbngpm32ngyv2";
  };
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = wallpaper;
      wallpaper = ", ${wallpaper}";
    };
  };
}
