{ pkgs, ... }:
{
  plugins = {
    treesitter = {
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
    treesitter-textobjects.enable = true; # Required by nvim-surround
    ts-context-commentstring.enable = true; # Required by comment.nvim
  };
}
