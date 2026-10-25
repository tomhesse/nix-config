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

      programs.vscode.profiles.default = lib.mkIf config.programs.vscode.enable {
        extensions = [
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              publisher = "opentofu";
              name = "vscode-opentofu";
              version = "0.6.2";
              hash = "sha256-rgp++YQ8gUBjzeZk3H0XIcDu2Cp7NGuoutI8IGo5cmg=";
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
