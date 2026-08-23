{
  flake.modules.nixos.thunderbird = {
    programs.thunderbird = {
      enable = true;

      policies = {
        DisableTelemetry = true;
        AppAutoUpdate = false;
      };
    };
  };

  flake.modules.homeManager.thunderbird =
    let
      profile = "tom";
    in
    {
      catppuccin.thunderbird.profile = profile;

      home.persistence."/persistent".directories = [ ".thunderbird" ];

      accounts.email.accounts."contact@tomhesse.xyz" = {
        primary = true;
        address = "contact@tomhesse.xyz";
        realName = "Tom Hesse";
        userName = "contact@tomhesse.xyz";
        imap = {
          host = "imap.mailbox.org";
          port = 993;
        };
        smtp = {
          host = "smtp.mailbox.org";
          port = 465;
        };
        folders = {
          inbox = "INBOX";
          sent = "Sent";
          drafts = "Drafts";
          trash = "Trash";
        };
        thunderbird.enable = true;
      };

      programs.thunderbird = {
        enable = true;

        profiles.${profile} = {
          isDefault = true;

          settings = {
            "extensions.autoDisableScopes" = 0;
            "mailnews.start_page.enabled" = false;
          };
        };
      };
    };
}
