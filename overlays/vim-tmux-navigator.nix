_: prev: {
  tmuxPlugins = prev.tmuxPlugins // {
    vim-tmux-navigator = prev.tmuxPlugins.vim-tmux-navigator.overrideAttrs (_: {
      version = "git-2025-01-01";
      src = prev.fetchFromGitHub {
        owner = "christoomey";
        repo = "vim-tmux-navigator";
        rev = "c45243dc1f32ac6bcf6068e5300f3b2b237e576a";
        sha256 = "sha256-IEPnr/GdsAnHzdTjFnXCuMyoNLm3/Jz4cBAM0AJBrj8=";
      };
    });
  };
}
