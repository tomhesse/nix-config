{ config, inputs, ... }:
let
  isEd25519 = key: key.type == "ed25519";
  getKeyPath = key: key.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../hosts/secrets.yaml;
    age.sshKeyPaths = map getKeyPath keys;
  };
}
