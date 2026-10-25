{
  flake.modules.homeManager.opentofu =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.opentofu ];

      programs.vscodium.profiles.default = lib.mkIf config.programs.vscodium.enable {
        extensions = [
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              publisher = "opentofu";
              name = "vscode-opentofu";
              version = "0.6.3";
              hash = "sha256-q1Em4j1vlwCKcoXWRUArVkGlAMIrGb9onJBWlUFjRgU=";
            };
          })
        ];

        userSettings = {
          "opentofu.languageServer.path" = "${pkgs.tofu-ls}/bin/tofu-ls";
          "opentofu.languageServer.tofu.path" = "${pkgs.opentofu}/bin/tofu";
        };
      };
    };
}
