{ pkgs, ... }:
{
  plugins.treesitter = {
    enable = true;
    grammarPackages = builtins.attrValues {
      inherit (pkgs.vimPlugins.nvim-treesitter.builtGrammars)
        markdown
        markdown_inline
        nix
        ;
    };
    settings = {
      highlight.enable = true;
      incremental_selection.enable = true;
      indent.enable = true;
    };
  };
}
