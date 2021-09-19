{ pkgs, ... }:

# make pkgs avaliable in lexical scope of the following expression
with pkgs;

# set the entire package as a local variable to include in environment.systemPackages
let myVim = vim_configurable.customize {
  
  # whatever name you want to use vim by
  # vim recommened 
  name = "vim";
  
  vimrcConfig = {
    
    # import .vimrc
    customRC = builtins.readFile ./.vimrc;
    
    # make plugins avaliable to vam
    vam.knownPlugins = pkgs.vimPlugins;
    
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
          "undotree"
          "vim-clap"
          "targets-vim"
          "coc-nvim"
          "vim-toml"
          "fzfWrapper"
          "fzf-vim"
          "echodoc-vim"
          "dracula-vim"
          "onehalf"
          "gruvbox"
          "zig-vim"
        ];
      }
    ];
  };
};
# include our customized vim package in systemPackages
in { 
  environment.systemPackages = with pkgs; [ myVim ]; 
  # set vim as default editor
  environment.variables = { EDITOR = "vim"; };
}
