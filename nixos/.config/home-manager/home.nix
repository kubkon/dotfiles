{ config, pkgs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

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

  home.packages = [
    pkgs._1password-cli
    pkgs._1password-gui
  ];

  xsession = {
    enable = true;
    # initExtra = ''
    #   xset r rate 190 35
    # '';
  };

  home.file.".ssh/allowed_signers".text = "* ${builtins.readFile ~/.ssh/id_ecdsa_sk.pub}";

  home.file.".config/ghostty/config".text = ''
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
      extraConfig = builtins.readFile ./default.conf;
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

    helix = {
      enable = true;
      package = pkgs.unstable.helix;
      defaultEditor = true;

      settings = {
        theme = "tokyonight";
        editor = {
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          bufferline = "multiple";
          statusline = {
            left = [
              "mode"
              "spinner"
              "spacer"
              "diagnostics"
              "file-name"
              "separator"
              "spacer"
              "version-control"
            ];
            right = [
              "file-type"
              "file-encoding"
              "file-line-ending"
              "position"
              "position-percentage"
              "total-line-numbers"
            ];
            separator = "⌥";
          };
          lsp = {
            display-inlay-hints = true;
          };
          end-of-line-diagnostics = "disable";
          inline-diagnostics = {
            cursor-line = "hint";
          };
        };

        keys = {
          normal = {
            C = [
              "extend_to_line_end"
              "yank_main_selection_to_clipboard"
              "delete_selection"
              "insert_mode"
            ];
            D = [
              "extend_to_line_end"
              "yank_main_selection_to_clipboard"
              "delete_selection"
            ];
            V = [
              "select_mode"
              "extend_to_line_bounds"
            ];
            "{" = [
              "extend_to_line_bounds"
              "goto_prev_paragraph"
            ];
            "}" = [
              "extend_to_line_bounds"
              "goto_next_paragraph"
            ];
            "*" = [
              "move_char_right"
              "move_prev_word_start"
              "move_next_word_end"
              "search_selection"
              "search_next"
            ];
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
          };

          insert = {
            esc = [
              "collapse_selection"
              "normal_mode"
            ];
          };

          select = {
            esc = [
              "collapse_selection"
              "keep_primary_selection"
              "normal_mode"
            ];
            "{" = [
              "extend_to_line_bounds"
              "goto_prev_paragraph"
            ];
            "}" = [
              "extend_to_line_bounds"
              "goto_next_paragraph"
            ];
          };
        };
      };

      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          }
          {
            name = "typescript";
            auto-format = true;
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "typescript"
              ];
            };
            language-servers = [
              "typescript-language-server"
            ];
          }
          {
            name = "tsx";
            auto-format = true;
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "typescript"
              ];
            };
            language-servers = [
              "typescript-language-server"
            ];
          }
          {
            name = "solidity";
            auto-format = true;
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "solidity-parse"
                "--plugin"
                "prettier-plugin-solidity"
              ];
            };
          }
        ];

        language-server = {
          rust-analyzer = {
            config = {
              cargo = {
                allFeatures = true;
              };
              check = {
                command = "clippy";
              };
              procMacro = {
                enable = false;
                ignored = { };
              };
              diagnostics = {
                disabled = [ "macro-error" ];
              };
            };
          };

          typescript-language-server = {
            command = "typescript-language-server";
            config.documentFormatting = false;
          };
        };
      };
    };
  };

}
