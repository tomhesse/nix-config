{
  hostName,
  inputs,
  osConfig,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./../hosts/${hostName}/secrets.yaml;
    age.keyFile = ''${osConfig.sops.secrets."users/tom/age-key".path}'';
  };
}
