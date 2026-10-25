{
  flake.modules.homeManager.nix-ide =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    {
      programs.vscodium.profiles.default = lib.mkIf config.programs.vscodium.enable {
        extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];

        userSettings =
          let
            host = osConfig.networking.hostName;
            flake = "(builtins.getFlake (builtins.toString ./. ))";
          in
          {
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
            "nix.serverSettings" = {
              "nixd" = {
                "formatting"."command" = [
                  "${pkgs.nixfmt}/bin/nixfmt"
                  "-"
                ];
                "nixpkgs"."expr" = "import ${flake}.inputs.nixpkgs { }";
                "options" = {
                  "nixos"."expr" = "${flake}.nixosConfigurations.${host}.options";
                  "home-manager"."expr" =
                    "${flake}.nixosConfigurations.${host}.options.home-manager.users.type.getSubOptions []";
                };
              };
            };
          };
      };
    };
}
