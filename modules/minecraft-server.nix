{
  flake.modules.nixos.minecraft-server =
    { lib, pkgs, ... }:
    let
      inherit (lib) concatStringsSep;
    in
    {
      services.minecraft-server = {
        enable = true;
        eula = true;
        openFirewall = true;
        package = pkgs.papermcServers.papermc-1_21_10;

        jvmOpts = concatStringsSep " " [
          "-Xms6144M"
          "-Xmx6144M"
          "-XX:+UseG1GC"
          "-XX:+ParallelRefProcEnabled"
          "-XX:MaxGCPauseMillis=200"
          "-XX:+UnlockExperimentalVMOptions"
          "-XX:+DisableExplicitGC"
          "-XX:+AlwaysPreTouch"
          "-XX:G1NewSizePercent=30"
          "-XX:G1MaxNewSizePercent=40"
          "-XX:G1HeapRegionSize=8M"
          "-XX:G1ReservePercent=20"
          "-XX:G1HeapWastePercent=5"
          "-XX:G1MixedGCCountTarget=4"
          "-XX:InitiatingHeapOccupancyPercent=15"
          "-XX:G1MixedGCLiveThresholdPercent=90"
          "-XX:G1RSetUpdatingPauseTimePercent=5"
          "-XX:SurvivorRatio=32"
          "-XX:+PerfDisableSharedMem"
          "-XX:MaxTenuringThreshold=1"
          "-Dusing.aikars.flags=https://mcflags.emc.gs"
          "-Daikars.new.flags=true"
        ];

        declarative = true;
        whitelist = {
          DerLoerris1234 = "c45260bb-067e-43b7-b6e5-57aef05f05a1";
          Heyhoman = "114613d9-18ec-472a-9740-02e8f5297c36";
        };
        serverProperties = {
          enforce-whitelist = true;
          force-gamemode = true;
          gamemode = "survival";
          max-players = 4;
          motd = "Shrimphouse Minecraft Server";
          region-file-compression = "none";
          simulation-distance = 10;
          spawn-protection = 0;
          view-distance = 16;
          white-list = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/minecraft 0755 minecraft minecraft -"
      ];
    };
}
