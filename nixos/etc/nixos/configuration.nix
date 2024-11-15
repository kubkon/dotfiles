# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-24.05";
  });
in {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/yubikey.nix
      nixvim.nixosModules.nixvim
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.kernelPackages = pkgs.linuxPackages_5_15;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rr-zen_workaround
  ];
  boot.kernelModules = [
    "zen_workaround"
  ];
  boot.supportedFilesystems = [ "ntfs" "jfs" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  hardware.tuxedo-keyboard.enable = true;
  boot.kernelParams = [
    "xhci_hcd.quirks=1073741824"
  ];

  # RR the perf!
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = 1;
  };

  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
  '';

  networking.hostName = "kurosaki"; # Define your hostname.
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    deviceSection = ''
      Option "TearFree" "true"
    '';
  };

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable i3wm with xfce
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager = {
    xterm.enable = false;
    xfce = {
      enable = true;
      noDesktop = true;
      enableXfwm = false;
    };
  };

  # Configure keymap in X11
  # services.xserver.layout = "us,us";
  services.xserver.xkb.layout = "us,us";
  # services.xserver.xkbVariant = "colemak,";
  services.xserver.xkb.variant = "colemak,";
  # services.xserver.xkbOptions = "grp:win_space_toggle,caps:escape";
  services.xserver.xkb.options = "grp:win_space_toggle,caps:escape";
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    # nssmdns = true;
    nssmdns4 = true;
  };

  # Enable sound
  nixpkgs.config.pulseaudio = true;
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth = {
    enable = true;
    settings = {
      Policy = {
        AutoEnable = true;
      };
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa = {
  #     enable = true;
  #     support32Bit = true;
  #   };
  #   pulse.enable = true;
  # };

  # AMD Graphics
  hardware.opengl.extraPackages = [
    pkgs.amdvlk
  ];

  # Enable scanners
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput = {
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
    };
  };

  programs.fish.enable = true;
  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    keymaps = [
      {
        mode = "n";
        key = "<CR>";
        options.silent = true;
        action = ":nohlsearch<CR>";
      }
      # Telescope config
      {
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
      }
      {
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
      }
      {
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
      }
      {
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
      }
    ];

    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
    };

    colorschemes.tokyonight.enable = true;

    plugins = {
      telescope = {
        enable = true;
        extensions = {
          fzf-native = {
            enable = true;
          };
        };
      };
      
      lsp = {
        enable = true;
        servers = {
          zls.enable = true;
        };
      };

      cmp = {
        enable = true;
        settings = {
          completion = {
            completeopt = "menu,menuone,noinsert";
          };
          autoEnableSources = true;
          experimental = { ghost_text = true; };
          performance = {
            debounce = 60;
            fetchingTimeout = 200;
            maxViewEntries = 30;
          };
          formatting = { fields = [ "kind" "abbr" "menu" ]; };
          sources = [
            { name = "nvim_lsp"; }
            { name = "emoji"; }
            {
              name = "buffer"; # text within current buffer
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              keywordLength = 3;
            }
            {
              name = "path"; # file system paths
              keywordLength = 3;
            }
          ];

          window = {
            completion = { border = "solid"; };
            documentation = { border = "solid"; };
          };

          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-e>" = "cmp.mapping.abort()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          };
        };
      };
      cmp-nvim-lsp.enable = true;
      cmp-path.enable = true;
      cmp-buffer.enable = true;

      lualine.enable = true;
      bufferline.enable = true;
      treesitter.enable = true;
      commentary.enable = true;
      zig.enable = true;

      conform-nvim = {
        enable = true;
        formatOnSave = {
          lspFallback = true;
          timeoutMs = 500;
        };
        notifyOnError = false;
        formattersByFt.rust = [ "rustfmt" ];
      };

      rustaceanvim = {
        enable = true;
        rustAnalyzerPackage = null;
        settings = {
          tools.enable_clippy = true;
          check = {
            command = "clippy";
          };
          cargo = {
            allFeatures = true;
          };
          inlayHints = { 
            lifetimeElisionHints = { 
              enable = "always";
            };
          };
        };
      };
    };

    extraConfigLuaPre = ''
      if vim.g.have_nerd_font then
        require('nvim-web-devicons').setup {}
      end
    '';

    extraConfigLua = ''
      -- LSP Diagnostics Options Setup 
      local sign = function(opts)
        vim.fn.sign_define(opts.name, {
          texthl = opts.name,
          text = opts.text,
          numhl = ""
        })
      end

      sign({ name = 'DiagnosticSignError', text = ' ' })
      sign({ name = 'DiagnosticSignWarn', text = ' ' })
      sign({ name = 'DiagnosticSignHint', text = '󰌶 ' })
      sign({ name = 'DiagnosticSignInfo', text = ' ' })

      vim.diagnostic.config({
          virtual_text = false,
          signs = true,
          update_in_insert = true,
          underline = true,
          severity_sort = false,
          float = {
              border = 'rounded',
              source = 'always',
              header = "",
              prefix = "",
          },
      })

      vim.cmd([[
      set signcolumn=yes
      autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
      ]])

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    '';
  };

  users.defaultUserShell = pkgs.fish;
  users.mutableUsers = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kubkon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "scanner" "lp" "libvirtd" ];
    hashedPassword = "deadbeef";
    openssh.authorizedKeys.keys = [
      "deadbeef"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
  };
  environment.localBinInPath = true;
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    vim
    wget
    thunderbird
    firefox
    nodejs
    ripgrep
    fzf
    libreoffice
    gimp
    signal-desktop
    fish
    starship
    kitty
    i3lock
    i3lock-fancy-rapid
    lxappearance
    autorandr
    htop
    obs-studio
    unstable.discord
    file
    chromium
    vlc
    skypeforlinux
    wineWowPackages.stable
    slack
    flameshot
    xss-lock
    signal-desktop
    fd
    lua
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.prettier
    libimobiledevice
    ifuse
    vscode
    xsaneGimp
    wireshark
    virt-manager
    qemu_full
    python3
    irssi
    yubikey-manager
  ];
  environment.variables.EDITOR = "nvim";

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  environment.stub-ld.enable = false;

  fonts.packages = with pkgs; [
    nerdfonts
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Enable iPhone tethering
  services.usbmuxd.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  documentation.dev.enable = true;
}

