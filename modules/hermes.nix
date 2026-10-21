{ inputs, ... }:
{
  flake-file.inputs.hermes-agent = {
    url = "github:NousResearch/hermes-agent";
    inputs = {
      flake-parts.follows = "flake-parts";
      home-manager.follows = "home-manager";
    };
  };

  flake.modules.nixos.hermes =
    { config, ... }:
    {
      sops =
        let
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        in
        {
          secrets = {
            "services/openrouter/api-key" = { inherit sopsFile; };
            "services/unifi-mcp/hermes-password" = {
              inherit sopsFile;
              owner = "thesse";
            };
            "services/hermes/mail-password" = {
              inherit sopsFile;
              owner = "thesse";
            };
          };

          templates."hermes-env" = {
            owner = "thesse";
            content = ''
              OPENROUTER_API_KEY=${config.sops.placeholder."services/openrouter/api-key"}
            '';
          };
        };
    };

  flake.modules.homeManager.hermes =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.hermes-agent.homeManagerModules.default ];

      programs.hermes-agent = {
        enable = true;
        desktop.enable = true;
      };

      services.hermes-agent = {
        enable = true;
        gateway.enable = true;

        hermesHome = "${config.xdg.dataHome}/hermes";

        environment.OBSIDIAN_VAULT_PATH = "${config.xdg.userDirs.documents}/obsidian/Prime Vault";

        environmentFiles = [ osConfig.sops.templates."hermes-env".path ];

        extraPackages = with pkgs; [
          curl
          findutils
          gawk
          gnugrep
          gnused
          himalaya
          jq
          python3
          ripgrep
        ];

        mcpServers = {
          homeassistant = {
            url = "https://ha.shrimphouse.xyz/api/mcp";
            auth = "oauth";
          };

          unifi-network = {
            command = lib.getExe' pkgs.uv "uvx";
            args = [
              "--python"
              (lib.getExe pkgs.python3)
              "unifi-network-mcp==0.39.1"
            ];
            env = {
              UV_PYTHON_DOWNLOADS = "never";
              UNIFI_NETWORK_HOST = "10.0.99.2";
              UNIFI_NETWORK_USERNAME = "hermes-mcp";
              UNIFI_NETWORK_PASSWORD_FILE = osConfig.sops.secrets."services/unifi-mcp/hermes-password".path;
              UNIFI_NETWORK_VERIFY_SSL = "false";
              UNIFI_POLICY_CREATE = "false";
              UNIFI_POLICY_UPDATE = "false";
              UNIFI_POLICY_DELETE = "false";
            };
          };
        };

        settings = {
          model = {
            provider = "openrouter";
            default = "z-ai/glm-5.2";
          };

          telemetry.shared_metrics = {
            enabled = false;
            send = false;
            offer_version = 2;
          };

          updates.check = false;

          auth.adopt_external_logins = false;

          approvals.deny = [
            "*sudo *"
            "*nixos-rebuild*"
            "*nh os *"
            "*git push*"
            "*himalaya*message send*"
            "*himalaya*message write*"
            "*himalaya*message reply*"
            "*himalaya*message forward*"
            "*himalaya*message edit*"
            "*himalaya*message mailto*"
            "*himalaya*template send*"
          ];

          display.skin = "catppuccin";

          sessions.auto_archive = true;
        };
      };

      programs.himalaya = {
        enable = true;
        package = null;
      };

      accounts.email.accounts."contact@tomhesse.xyz" = {
        himalaya.enable = true;
        passwordCommand = [
          (lib.getExe' pkgs.coreutils "cat")
          osConfig.sops.secrets."services/hermes/mail-password".path
        ];
      };

      xdg.configFile."Hermes/minimize-to-tray.json" = {
        text = builtins.toJSON { enabled = true; };
        force = true;
      };

      home.persistence."/persistent".directories = [
        "${config.xdg.relativeDataHome}/hermes"
        "${config.xdg.relativeConfigHome}/Hermes"
      ];
    };
}
