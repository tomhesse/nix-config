{ inputs, ... }:
{
  flake.modules.nixos.sops =
    { config, ... }:
    let
      isEd25519 = key: key.type == "ed25519";
      keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.sshKeyPaths = map (key: key.path) keys;
      };
    };
}
