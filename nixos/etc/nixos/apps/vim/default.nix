{ pkgs, ... }:

# make pkgs avaliable in lexical scope of the following expression
with pkgs;

# set the entire package as a local variable to include in environment.systemPackages
let 
  customNvimPlugins = {
    gruvbox-baby = vimUtils.buildVimPlugin {
      name = "gruvbox-baby";
      src = fetchFromGitHub {
        owner = "luisiacc";
        repo = "gruvbox-baby";
        rev = "a2c70e7203338ee301325aed5b97337bcce30b5b";
        sha256 = "04hsjhc7qg7bin86y904j4w8q6n1064n8xy1yi5a1zqzpw8x2nkm";
      };
    };
  };
  myVim = vim_configurable.customize {
    name = "vim";

    vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
    vimrcConfig.vam.pluginDictionaries = [
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
    
    vimrcConfig.customRC = builtins.readFile ./.vimrc;
  };
  myNvim = pkgs.neovim.override {
    configure = {
      customRC = builtins.readFile ./init.vim;

      packages.myPlugins = with pkgs.vimPlugins // customNvimPlugins; {
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
          telescope-nvim
          plenary-nvim
          nvim-web-devicons
          echodoc-vim
          dracula-vim
          onehalf
          gruvbox
          zig-vim
          fugitive
          (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
          nvim-treesitter-context
          nvim-lspconfig
          nvim-cmp
          cmp-nvim-lsp
          cmp_luasnip
          luasnip
          nightfox-nvim
          gruvbox-baby
          vim-javascript
          typescript-vim
        ];
        opt = [];
      };
    };
  };
# include our customized vim package in systemPackages
in { 
  environment.systemPackages = with pkgs; [ myVim myNvim ]; 
  # set vim as default editor
  environment.variables = { EDITOR = "vim"; };
}
