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
  ];

  programs = {
    kitty = {
      enable = true;
      font.name = "DejaVuSansMono Nerd Font Mono";
      font.size = 10;
      extraConfig = ''
# gruvbox dark by morhetz, https://github.com/morhetz/gruvbox
# This work is licensed under the terms of the MIT license.
# For a copy, see https://opensource.org/licenses/MIT.

background  #282828
foreground  #ebdbb2

cursor                #928374

selection_foreground  #928374
selection_background  #3c3836

color0  #282828
color8  #928374

# red
color1                #cc241d
# light red
color9                #fb4934

# green
color2                #98971a
# light green
color10               #b8bb26

# yellow
color3                #d79921
# light yellow
color11               #fabd2d

# blue
color4                #458588
# light blue
color12               #83a598

# magenta
color5                #b16286
# light magenta
color13               #d3869b

# cyan
color6                #689d6a
# lighy cyan
color14               #8ec07c

# light gray
color7                #a89984
# dark gray
color15               #928374
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
      ];
    };
  };
}
