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
      programs.vscode.profiles.default = lib.mkIf config.programs.vscode.enable {
        extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];

        userSettings =
          let
            host = osConfig.networking.hostName;
            flake = "(builtins.getFlake (builtins.toString ./. ))";
          in
          {
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
            "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
            "nix.serverSettings" = {
              "nixd" = {
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
