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
        defaultSopsFile = ./secrets/nixos.yaml;
        age.sshKeyPaths = map (key: key.path) keys;
      };
    };

  flake.modules.homeManager.sops =
    {
      config,
      osConfig ? null,
      ...
    }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        defaultSopsFile = ./secrets + "/${config.home.username}.yaml";
        age.keyFile =
          if osConfig != null then
            osConfig.sops.secrets."users/${config.home.username}/age-key".path
          else
            "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
