{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "kubkon";
  home.homeDirectory = "/home/kubkon";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";

  home.packages = with pkgs; [
    htop
    obs-studio
    discord
    file
    chromium
    vlc
    skype
    wineWowPackages.stable
  ];

  programs = {
    kitty = {
      enable = true;
      font.name = "DejaVuSansMono Nerd Font Mono";
      font.size = 10;
      extraConfig = ''
background            #202020
foreground            #d0d0d0
cursor                #d0d0d0
selection_background  #303030
color0                #151515
color8                #505050
color1                #ac4142
color9                #ac4142
color2                #7e8d50
color10               #7e8d50
color3                #e5b566
color11               #e5b566
color4                #6c99ba
color12               #6c99ba
color5                #9e4e85
color13               #9e4e85
color6                #7dd5cf
color14               #7dd5cf
color7                #d0d0d0
color15               #f5f5f5
selection_foreground #202020
      '';
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      # initExtra = "export PATH=$PATH:~/bin";
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    tmux = {
      enable = true;
      terminal = "screen-256color";
      historyLimit = 5000;
      escapeTime = 0;
    };

    git = {
      enable = true;
      userName = "Jakub Konka";
      userEmail = "kubkon@jakubkonka.com";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        merge = {
          conflictstyle = "diff3";
          tool = "vimdiff";
          prompt = false;
        };
      };
      ignores = [
        "*.swp"
        "zig-cache"
        "zig-out"
        ".cache"
        ".ccls"
        ".ccls-cache"
        "compile_commands.json"
        "shell.nix"
      ];
    };
  };
}
