{ self, ... }:
{
  flake.modules.nixos.zfs =
    { config, pkgs, ... }:
    {
      imports = [ self.modules.nixos.msmtp ];

      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs.forceImportRoot = false;

      services.zfs.autoScrub = {
        enable = true;
        interval = "monthly";
      };

      services.zfs.zed = {
        enableMail = false;
        settings = {
          ZED_EMAIL_ADDR = [ config.msmtp.adminAddress ];
          ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
          ZED_EMAIL_OPTS = "@ADDRESS@ --set-from-header=auto -f zed@${config.msmtp.senderDomain}";
        };
      };
    };
}
