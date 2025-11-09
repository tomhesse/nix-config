{ config, ... }:
{
  sops.secrets."mail/contact@tomhesse.xyz/password" = { };

  programs.aerc = {
    enable = true;
    extraConfig.general.unsafe-accounts-conf = true;
    extraConfig = {
      filters = {
        "text/plain" = "colorize";
        "text/html" = "html | colorize";
      };
    };
  };

  accounts.email.accounts = {
    "contact@tomhesse.xyz" = {
      aerc.enable = true;
      primary = true;
      realName = "Tom hesse";
      address = "contact@tomhesse.xyz";
      userName = "contact@tomhesse.xyz";
      passwordCommand = ''cat ${config.sops.secrets."mail/contact@tomhesse.xyz/password".path}'';
      imap.host = "imap.mailbox.org";
      smtp.host = "smtp.mailbox.org";
      folders = {
        inbox = "INBOX";
        sent = "Sent";
        drafts = "Drafts";
        trash = "Trash";
      };
    };
  };
}
