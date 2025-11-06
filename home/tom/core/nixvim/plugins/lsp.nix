{ hmConfig, ... }:
{
  plugins.lsp = {
    enable = true;
    inlayHints = true;
    servers = {
      nixd = {
        enable = true;
        settings =
          let
            flake = "(builtins.getFlake (builtins.toString ./.))";
            inherit (hmConfig) hostName;
          in
          {
            options = {
              nixos.expr = "${flake}.nixosConfigurations.${hostName}.options";
              home-manager.expr = "${flake}.nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []";
              nixvim.expr = "(${flake}.inputs.nixvim.lib.evalNixvim { system = builtins.currentSystem; }).options";
              flake-parts.expr = "${flake}.debug.options // ${flake}.currentSystem.options";
            };
          };
      };
    };
  };
}
