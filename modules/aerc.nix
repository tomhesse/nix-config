{
  flake.modules.homeManager.aerc =
    { config, osConfig, ... }:
    {
      accounts.email.accounts."contact@tomhesse.xyz" = {
        primary = true;
        address = "contact@tomhesse.xyz";
        realName = "Tom Hesse";
        userName = "contact@tomhesse.xyz";
        passwordCommand = "cat ${config.sops.secrets."mail/contact@tomhesse.xyz/password".path}";
        imap.host = "imap.mailbox.org";
        smtp.host = "smtp.mailbox.org";
        folders = {
          inbox = "INBOX";
          sent = "Sent";
          drafts = "Drafts";
          trash = "Trash";
        };
        aerc.enable = true;
      };

      programs.aerc = {
        enable = true;
        extraConfig = {
          general.unsafe-accounts-conf = true;
          filters = {
            "text/plain" = "colorize";
            "text/html" = "html | colorize";
          };
        };
      };

      sops.secrets."mail/contact@tomhesse.xyz/password" = {
        sopsFile = ./hosts/${osConfig.networking.hostName}/secrets/thesse.yaml;
      };
    };
}
