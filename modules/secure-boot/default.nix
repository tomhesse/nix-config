{
  flake.modules.nixos.secure-boot =
    { pkgs, ... }:
    let
      cryptenroll = pkgs.writeShellApplication {
        name = "cryptenroll";
        runtimeInputs = [ pkgs.systemd ];
        text = builtins.readFile ./cryptenroll.sh;
      };
    in
    {
      boot.loader.limine.secureBoot.enable = true;

      environment.systemPackages = [ cryptenroll ];

      environment.persistence."/persistent".directories = [
        "/var/lib/sbctl"
      ];
    };
}
