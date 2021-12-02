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
  ];

  programs = {
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
      ];
    };
  };
}
