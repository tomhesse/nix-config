{ inputs, ... }:
{
  flake.modules.homeManager.lazygit =
    { config, pkgs, ... }:
    {
      home.persistence."/persistent".files = [
        "${config.xdg.relativeStateHome}/lazygit/state.yml"
      ];

      # HACK: pre-migrate the theme until the catppuccin input tracks release-26.11.
      # lazygit migrates stale config keys unconditionally and then fails writing
      # the result back to the read-only store, so hand it an already-migrated
      # theme. The port moved authorColors under gui.theme in catppuccin/nix#1049,
      # but release-26.05 froze its port sources at the branch cut and will not
      # get it. The skip-if-nested check makes this a plain copy by then.
      catppuccin.sources.lazygit =
        pkgs.runCommand "catppuccin-lazygit-migrated"
          {
            src = inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.lazygit;
            nativeBuildInputs = [ pkgs.yq-go ];
          }
          ''
            cp -r "$src" "$out"
            chmod -R u+w "$out"

            for theme in "$out"/*/*.yml; do
              if [ "$(yq '.gui | has("authorColors")' "$theme")" = "true" ]; then
                yq -i '.gui.theme.authorColors = .gui.authorColors | del(.gui.authorColors)' "$theme"
              fi
            done
          '';

      programs.lazygit = {
        enable = true;
        settings = {
          promptToReturnFromSubprocess = false;
          git.autoFetch = false;
          git.overrideGpg = true;
          gui.mouseEvents = false;
        };
      };
    };
}
