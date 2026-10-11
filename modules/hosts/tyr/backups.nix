{
  configurations.nixos.tyr.module = {
    services.restic.backups = {
      persistent.exclude = [
        "**/steamapps/common"
        "**/steamapps/shadercache"
      ];

      offsite.timerConfig.OnCalendar = "22:00";
    };

    restic.offsite.user = "u591202-sub2";
  };
}
