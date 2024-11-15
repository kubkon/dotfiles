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
  home.stateVersion = "21.11";
  home.sessionVariables.EDITOR = "nvim";

  xsession = {
    enable = true;
    # initExtra = ''
    #   xset r rate 190 35
    # '';
  };

  home.file.".ssh/allowed_signers".text =
    "* ${builtins.readFile ~/.ssh/id_ecdsa_sk.pub}";

  home.file."~/.config/ghostty".text = ''
    font-size = 12
    background = 282828
    foreground = dedede
    keybind = ctrl+d=new_split:right
    keybind = ctrl+left_bracket=goto_split:left
    keybind = ctrl+right_bracket=goto_split:right
    keybind = ctrl+shift+left_bracket=previous_tab
    keybind = ctrl+shift+right_bracket=next_tab
  '';

  programs = {
    kitty = {
      enable = true;
      font.name = "DejaVuSansMono Nerd Font Mono";
      font.size = 10;
      keybindings = {
        "ctrl+shift+[" = "prev_tab";
        "ctrl+shift+]" = "next_tab";
      };
      extraConfig = builtins.readFile ./default.conf ;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        {
          name = "bobthefish";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "theme-bobthefish";
            rev = "06ebe3b9af9af2e30f104b0956e255ca42ed5cab";
            sha256 = "7G0QSCwZYxNguUot0IVdzbCRFK/6l7WSRIBPOHo3gR0=";
          };
        }
      ];
    };

    git = {
      enable = true;
      userName = "Jakub Konka";
      userEmail = "kubkon@jakubkonka.com";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        http.version = "HTTP/1.1";
        merge = {
          conflictstyle = "diff3";
          tool = "vimdiff";
          prompt = false;
        };
        # Sign all commits using ssh key
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        user.signingkey = "~/.ssh/id_ecdsa_sk.pub";
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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
