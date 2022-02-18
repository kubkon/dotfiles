{ pkgs, ... }:

# make pkgs avaliable in lexical scope of the following expression
with pkgs;

# set the entire package as a local variable to include in environment.systemPackages
let 
  customPlugins = {
    asyncomplete-lsp-vim = vimUtils.buildVimPlugin {
      name = "asyncomplete-lsp-vim";
      src = fetchFromGitHub {
        owner = "prabirshrestha";
        repo = "asyncomplete-lsp.vim";
        rev = "684c34453db9dcbed5dbf4769aaa6521530a23e0";
        sha256 = "0vqx0d6iks7c0liplh3x8vgvffpljfs1j3g2yap7as6wyvq621rq";
      };
    };
  };
  myVim = vim_configurable.customize {
    # whatever name you want to use vim by
    # vim recommened 
    name = "vim";
    
    vimrcConfig = {
      
      # import .vimrc
      customRC = builtins.readFile ./.vimrc;
      
      # make plugins avaliable to vam
      vam.knownPlugins = pkgs.vimPlugins // customPlugins;
      
      # declare plugins to use
      vam.pluginDictionaries = [
        { 
          names = [
            "vim-nix"
            "ctrlp"
            "nerdtree"
            "nerdtree-git-plugin"
            "vim-airline"
            "vim-commentary"
            "vim-easymotion"
            "vim-surround"
            "auto-pairs"
            "undotree"
            "vim-clap"
            "targets-vim"
            "async-vim"
            "asyncomplete-vim"
            "vim-lsp"
            "asyncomplete-lsp-vim"
            "vim-toml"
            "fzfWrapper"
            "fzf-vim"
            "echodoc-vim"
            "dracula-vim"
            "onehalf"
            "gruvbox"
            "zig-vim"
            "fugitive"
          ];
        }
      ];
    };
  };
  myNvim = neovim.override {
    configure = {
      customRC = builtins.readFile ./init.vim;

      packages.myPlugins = with pkgs.vimPlugins; {
        start = [ 
          ctrlp
          vim-nix
          nerdtree
          nerdtree-git-plugin
          vim-airline
          vim-commentary
          vim-easymotion
          vim-surround
          auto-pairs
          undotree
          vim-clap
          targets-vim
          vim-toml
          fzf-vim
          echodoc-vim
          dracula-vim
          onehalf
          gruvbox
          zig-vim
          fugitive
          (nvim-treesitter.withPlugins (_: tree-sitter.allGrammars))
          nvim-treesitter-context
          nvim-lspconfig
          nvim-cmp
          cmp-nvim-lsp
          cmp_luasnip
          luasnip
        ];
        opt = [];
      };
    };
  };
# include our customized vim package in systemPackages
in { 
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];
  environment.systemPackages = with pkgs; [ myVim myNvim ]; 
  # set vim as default editor
  environment.variables = { EDITOR = "vim"; };
}
