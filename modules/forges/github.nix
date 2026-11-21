{ self, ... }:
{
  flake.modules.nixos.github =
    { pkgs, ... }:
    let
      githubHostKeys = pkgs.writeText "github-host-keys" ''
        github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
        github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
      '';
    in
    {
      programs.ssh.knownHosts."github.com".publicKeyFile = githubHostKeys;
    };

  flake.modules.homeManager.github =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.homeManager.gpg ];

      # GitHub signs the commits it creates itself — squash merges, rebases and web
      # edits — with its own key, so those commits only verify locally once it is in
      # the keyring. Ultimate trust is what makes git report them as good rather
      # than untrusted; the key certifies nothing else, so it introduces no one.
      programs.gpg.publicKeys = [
        {
          source = ./github.asc;
          trust = "ultimate";
        }
      ];

      programs.vscodium.profiles.default = lib.mkIf config.programs.vscodium.enable {
        extensions = [
          pkgs.vscode-extensions.github.vscode-github-actions
          pkgs.vscode-extensions.github.vscode-pull-request-github
        ];
      };
    };
}
