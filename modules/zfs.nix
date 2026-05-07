{
  flake.modules.nixos.zfs =
    { pkgs, ... }:
    {
      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs.forceImportRoot = false;

      services.zfs.autoScrub = {
        enable = true;
        interval = "monthly";
      };

      services.zfs.zed = {
        enableMail = false;
        settings = {
          ZED_EMAIL_ADDR = [ "admin@shrimphouse.xyz" ];
          ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
          ZED_EMAIL_OPTS = "@ADDRESS@ --set-from-header=auto -f zed@mail.shrimphouse.xyz";
        };
      };
    };
}
