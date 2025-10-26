let
  encoding = "utf-8";
  indent = 4;
in
{
  opts = {
    mouse = ""; # Disable mouse support
    inherit encoding; # Internal encoding used by neovim
    fileencoding = encoding; # The encoding written to a file

    autoindent = true;
    expandtab = true; # Convert tabs to spaces
    smartindent = true;
    tabstop = indent; # Number of spaces that a tab counts for
    softtabstop = indent; # Number of spaces a tab counts while editing
    shiftwidth = indent; # Number of spaces use for (auto)indent
    backspace = "indent,eol,start"; # Allow backspace on indent, and of line or insert mode start position

    hlsearch = true; # Highlight all matches
    ignorecase = true; # Ignore case in search patterns
    smartcase = true; # Overwrite ignorecase when pattern contains upper case
    incsearch = true; # Start searching while typing

    cursorline = true;
    scrolloff = 5; # Always keep lines under the cursor
    colorcolumn = "120";
    showmode = false; # Mode is already in lualine
    number = true;
    relativenumber = true;
    wrap = false; # Disable line wrap
    signcolumn = "yes"; # Show sign column so that text doesn't shift

    splitright = true; # Split vertical window to the right
    splitbelow = true; # Split horizontal window to the bottom
  };
}
