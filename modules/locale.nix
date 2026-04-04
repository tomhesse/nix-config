{
  flake.modules.nixos.locale =
    { lib, ... }:
    {
      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    };

  flake.modules.homeManager.locale = {
    home.language.collate = "C.UTF-8";
  };
}
