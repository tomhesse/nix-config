{
  flake.modules.nixos.podman =
    { config, lib, ... }:
    let
      inherit (lib) mkOption types;
    in
    {
      options.podman.networks = mkOption {
        type = types.attrsOf (
          types.submodule (
            { name, ... }:
            {
              options = {
                interface = mkOption {
                  type = types.str;
                  default = "br-${name}";
                  description = "Host-side bridge interface. Max 15 characters.";
                };

                subnet = mkOption {
                  type = types.str;
                  description = "IPv4 subnet in CIDR notation.";
                };

                gateway = mkOption {
                  type = types.str;
                  description = "IPv4 gateway, held by the host on the bridge.";
                };

                internal = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Deny the network any route off the bridge.";
                };
              };
            }
          )
        );
        default = { };
        description = ''
          Podman bridge networks. `virtualisation.oci-containers` only passes
          `--network=<name>` to `podman run`; nothing upstream creates the
          network. Each entry here gets a oneshot that creates it, and every
          container listing it in `networks` is ordered after that oneshot.
        '';
      };

      config = {
        assertions = lib.mapAttrsToList (name: net: {
          assertion = builtins.stringLength net.interface <= 15;
          message = "podman.networks.${name}.interface exceeds the 15 character kernel limit.";
        }) config.podman.networks;

        podman.networks.edge = {
          subnet = "172.31.0.0/24";
          gateway = "172.31.0.1";
        };

        virtualisation = {
          oci-containers.backend = "podman";

          podman = {
            enable = true;
            dockerSocket.enable = true;
          };
        };

        systemd = {
          network.networks."05-podman" = {
            matchConfig.Name = lib.concatStringsSep " " (
              lib.mapAttrsToList (_: net: net.interface) config.podman.networks
              ++ [
                "veth*"
                "podman*"
              ]
            );
            linkConfig.Unmanaged = true;
          };

          services = lib.mkMerge [
            (lib.mapAttrs' (
              name: net:
              lib.nameValuePair "podman-network-${name}" {
                description = "Podman network ${name}";
                path = [ config.virtualisation.podman.package ];
                wantedBy = [ "multi-user.target" ];
                after = [ "network-online.target" ];
                wants = [ "network-online.target" ];

                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                };

                script = ''
                  podman network exists ${name} || podman network create \
                    --driver bridge \
                    --interface-name ${net.interface} \
                    --subnet ${net.subnet} \
                    --gateway ${net.gateway} \
                    ${lib.optionalString net.internal "--internal"} \
                    ${name}
                '';
              }
            ) config.podman.networks)

            (lib.mapAttrs' (
              _: container:
              lib.nameValuePair container.serviceName (
                let
                  units = map (n: "podman-network-${n}.service") (
                    builtins.filter (n: config.podman.networks ? ${n}) container.networks
                  );
                in
                {
                  after = units;
                  requires = units;
                }
              )
            ) config.virtualisation.oci-containers.containers)

            {
              podman-prune-images = {
                description = "Prune unused podman images";
                startAt = "Mon 04:00";

                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = "${config.virtualisation.podman.package}/bin/podman image prune --all --force --filter until=720h";
                };
              };
            }
          ];

          timers = {
            podman-prune.enable = false;

            podman-prune-images.timerConfig = {
              Persistent = true;
              RandomizedDelaySec = 1800;
            };
          };
        };
      };
    };
}
