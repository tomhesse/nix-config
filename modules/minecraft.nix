{
  flake.modules.nixos.minecraft =
    let
      uid = 410;

      whitelist = [
        "c45260bb-067e-43b7-b6e5-57aef05f05a1"
        "114613d9-18ec-472a-9740-02e8f5297c36"
      ];
    in
    {
      virtualisation.oci-containers.containers.minecraft = {
        image = "docker.io/itzg/minecraft-server:2026.9.2-java21";

        networks = [ "edge" ];

        ports = [ "25565:25565" ];

        volumes = [ "/srv/services/minecraft:/data" ];

        environment = {
          CUSTOM_SERVER_PROPERTIES = "region-file-compression=none";
          ENABLE_RCON = "false";
          EULA = "TRUE";
          FORCE_GAMEMODE = "true";
          GID = toString uid;
          MAX_PLAYERS = "4";
          MEMORY = "6144M";
          MODE = "survival";
          MOTD = "Shrimphouse Minecraft Server";
          SIMULATION_DISTANCE = "10";
          SPAWN_PROTECTION = "0";
          TYPE = "PAPER";
          TZ = "Europe/Berlin";
          UID = toString uid;
          USE_AIKAR_FLAGS = "true";
          VERSION = "1.21.10";
          VIEW_DISTANCE = "16";
          WHITELIST = builtins.concatStringsSep "," whitelist;
        };

        extraOptions = [ "--security-opt=no-new-privileges" ];
      };

      users = {
        groups.minecraft.gid = uid;

        users.minecraft = {
          isSystemUser = true;
          group = "minecraft";
          inherit uid;
        };
      };

      systemd = {
        services.podman-minecraft = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = "/srv/services/minecraft";
        };

        tmpfiles.rules = [ "d /srv/services/minecraft 0700 minecraft minecraft -" ];
      };
    };
}
