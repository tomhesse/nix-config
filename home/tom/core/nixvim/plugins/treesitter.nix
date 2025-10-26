{ pkgs, ... }:
{
  plugins.treesitter = {
    enable = true;
    grammarPackages = builtins.attrValues {
      inherit (pkgs.vimPlugins.nvim-treesitter.builtGrammars)
        markdown
        nix
        ;
    };
    settings = {
      highlight = {
        enable = true;
        additional_vim_regex_highlighting = false;
      };
      incremental_selection.enable = true;
      indent.enable = true;
    };
  };
}
